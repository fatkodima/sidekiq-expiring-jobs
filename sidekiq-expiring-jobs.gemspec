# frozen_string_literal: true

require_relative "lib/sidekiq_expiring_jobs/version"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-expiring-jobs"
  spec.version = SidekiqExpiringJobs::VERSION
  spec.authors = ["fatkodima"]
  spec.email = ["fatkodima123@gmail.com"]

  spec.summary = "Expiring jobs support for Sidekiq."
  spec.description = <<~DESC
    Support for Sidekiq jobs which expire after a certain length of time.
    Jobs that are set to expire can run as long as they want, but an expiring job
    must start executing before the expiration time.
  DESC
  spec.homepage = "https://github.com/fatkodima/sidekiq-expiring-jobs"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["*.{md,txt}", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 6.0"
end
