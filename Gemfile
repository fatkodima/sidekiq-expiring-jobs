# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sidekiq-expiring-jobs.gemspec
gemspec

gem "rake", "~> 13.0"
gem "minitest", "~> 5.0"
gem "rubocop", "< 2"
gem "rubocop-minitest"

if defined?(@sidekiq_requirement)
  gem "sidekiq", @sidekiq_requirement
else
  gem "sidekiq", "> 6" # min sidekiq version
end
