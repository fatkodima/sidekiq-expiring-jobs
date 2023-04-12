# frozen_string_literal: true

class BaseJob
  include Sidekiq::Job

  def perform
    puts "#{self.class.name} performed"
  end
end

class TestJob < BaseJob
end

class ExpiringJob01 < BaseJob
  sidekiq_options expires_in: 0.1
end

class ExpiringJob100 < BaseJob
  sidekiq_options expires_in: 100
end

class TerminateJob
  include Sidekiq::Job

  def perform
    Process.kill("TERM", Process.pid)
  end
end
