# SidekiqExpiringJobs

[![Build Status](https://github.com/fatkodima/sidekiq-expiring-jobs/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/fatkodima/sidekiq-expiring-jobs/actions/workflows/ci.yml)

Support for Sidekiq jobs which expire after a certain length of time.
Jobs that are set to expire can run as long as they want, but an expiring job must start executing before the expiration time.

Note: Sidekiq Pro has this feature, so please consider upgrading if you can.

## Use Cases

1. Perhaps you want to expire a cache which has a TTL of 30 minutes with a Sidekiq job. If the job doesn't process successfully within 30 minutes, there's no point in executing the job.
2. You use a Sidekiq job to send a daily digest email. If the job doesn't execute within 24 hours, perhaps you want to skip that day as the user might only care about the latest digest.
3. You enqueue periodically a Sidekiq job to do some task. If the job doesn't execute before the next period begins, you may skip that job as the newly enqueued job will do the task.

## Requirements

- Ruby 3.2+
- Sidekiq 8.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-expiring-jobs'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install sidekiq-expiring-jobs
```

## Defining Expiration

Statically:

```ruby
class SomeJob
  include Sidekiq::Job
  sidekiq_options expires_in: 1.hour
  ...
end
```

Dynamically, per job:

```ruby
SomeJob.set(expires_in: 1.day).perform_async(...)
```

`expires_in` must be a relative time, not an absolute timestamp.

Expiration knows about scheduled jobs: schedule a job to run two hours from now with a one hour expiration and it will expire **three** hours from now.

## Configuration

You can override the following default options:

```ruby
# A callback that is called when the job is expired.
# Accepts a job hash as an argument.
SidekiqExpiringJobs.expiration_callback = ->(job) {}
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fatkodima/sidekiq-expiring-jobs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
