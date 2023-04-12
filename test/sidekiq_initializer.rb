# frozen_string_literal: true

require "sidekiq"
require "sidekiq_expiring_jobs"

require_relative "jobs"

Sidekiq.configure_server do |config|
  config[:poll_interval_average] = 0.1 # do not waste time in tests
end

SidekiqExpiringJobs.expiration_callback = ->(_job) { puts "expiration_callback called" }
