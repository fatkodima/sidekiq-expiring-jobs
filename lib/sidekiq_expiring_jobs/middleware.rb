# frozen_string_literal: true

module SidekiqExpiringJobs
  module Middleware
    class Client
      def call(_worker_class, job, _queue, _redis_pool)
        # The job is requeued, e.g. by sidekiq-throttled gem. Do not update the expiration time.
        if job["expires_at"] && job["expires_at"] < Time.now.to_f
          Sidekiq.logger.info("[SidekiqExpiringJobs] Expired #{job['class']} job (jid=#{job['jid']}) is skipped")
          SidekiqExpiringJobs.expiration_callback&.call(job)

          return false
        end

        if (expires_in = job.delete("expires_in")) && job["expires_at"].nil?
          expires_in = expires_in.to_f
          raise ArgumentError, ":expires_in must be a relative time, not absolute time" if expires_in > 1_000_000_000

          # created_at is stored in milliseconds starting from sidekiq 8.0.
          at = job["at"] || (job["created_at"] / 1000.0)
          job["expires_at"] = at + expires_in
        end
        yield
      end
    end

    class Server
      def call(_worker, job, _queue)
        if job["expires_at"] && job["expires_at"] < Time.now.to_f
          Sidekiq.logger.info("[SidekiqExpiringJobs] Expired #{job['class']} job (jid=#{job['jid']}) is skipped")
          SidekiqExpiringJobs.expiration_callback&.call(job)
        else
          yield
        end
      end
    end
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add(SidekiqExpiringJobs::Middleware::Client)
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add(SidekiqExpiringJobs::Middleware::Client)
  end

  config.server_middleware do |chain|
    chain.add(SidekiqExpiringJobs::Middleware::Server)
  end
end
