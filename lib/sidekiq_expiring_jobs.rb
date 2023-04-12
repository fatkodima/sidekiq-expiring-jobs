# frozen_string_literal: true

require "sidekiq"

require_relative "sidekiq_expiring_jobs/version"

module SidekiqExpiringJobs
  class << self
    attr_accessor :expiration_callback
  end

  self.expiration_callback = ->(job) {}
end

require_relative "sidekiq_expiring_jobs/middleware"
