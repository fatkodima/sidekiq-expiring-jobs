# frozen_string_literal: true

require "sidekiq/api"
require_relative "test_helper"
require_relative "jobs"

class SidekiqExpiringJobsTest < TestCase
  def test_expired_job_not_performed
    out = perform_enqueued_jobs(delay: 0.2) do
      ExpiringJob01.perform_async
    end
    assert_not_match("ExpiringJob01 performed", out)
    assert_match("[SidekiqExpiringJobs] Expired ExpiringJob01 job", out)
  end

  def test_non_expired_job_performed
    out = perform_enqueued_jobs do
      ExpiringJob100.perform_async
    end
    assert_match("ExpiringJob100 performed", out)
    assert_not_match("[SidekiqExpiringJobs] Expired ExpiringJob100 job", out)
  end

  def test_regular_job_performed
    out = perform_enqueued_jobs do
      TestJob.perform_async
    end
    assert_match("TestJob performed", out)
  end

  def test_expired_scheduled_job_not_performed
    out = perform_enqueued_jobs(delay: 0.3) do # 0.1s delay + 0.1s expiration + 0.1
      ExpiringJob01.perform_in(0.1)
    end
    assert_not_match("ExpiringJob01 performed", out)
    assert_match("[SidekiqExpiringJobs] Expired ExpiringJob01 job", out)
  end

  def test_non_expired_scheduled_job_performed
    out = perform_enqueued_jobs(delay: 0.2) do
      ExpiringJob100.perform_in(0.1)
    end
    assert_match("ExpiringJob100 performed", out)
  end

  def test_dynamically_expired_job_not_performed
    out = perform_enqueued_jobs(delay: 0.2) do
      TestJob.set(expires_in: 0.1).perform_async
    end
    assert_not_match("TestJob performed", out)
    assert_match("[SidekiqExpiringJobs] Expired TestJob job", out)
  end

  def test_dynamically_non_expired_job_performed
    out = perform_enqueued_jobs do
      TestJob.set(expires_in: 100).perform_async
    end
    assert_match("TestJob performed", out)
  end

  def test_absolute_time_as_expiration
    error = assert_raises(ArgumentError) do
      AbsTimeExpiringJob.perform_async
    end
    assert_equal ":expires_in must be a relative time, not absolute time", error.message
  end

  def test_expiration_callback
    out = perform_enqueued_jobs(delay: 0.2) do
      ExpiringJob01.perform_async
    end
    assert_match("expiration_callback called", out)
  end

  def test_job_with_existing_expires_at_is_not_modified
    expires_at = Time.now.to_i + 100
    ExpiringJob01.set(expires_at: expires_at).perform_async

    job = Sidekiq::Queue.new.to_a.last
    assert_equal(expires_at, job["expires_at"])
  end

  def test_already_expired_job_is_not_enqueued
    expires_at = Time.now.to_i - 100
    ExpiringJob01.set(expires_at: expires_at).perform_async
    assert_equal(0, Sidekiq::Queue.new.size)
  end

  private
    def perform_enqueued_jobs(delay: 0)
      yield
      TerminateJob.perform_in(delay + 0.1) # run after enqueued scheduled jobs
      sleep(delay) if delay > 0
      out, = capture_subprocess_io do
        start_worker_and_wait
      end
      out
    end

    def start_worker_and_wait
      pid = spawn("bundle exec sidekiq --require ./test/sidekiq_initializer.rb --concurrency 1")
    ensure
      Process.wait(pid)
    end
end
