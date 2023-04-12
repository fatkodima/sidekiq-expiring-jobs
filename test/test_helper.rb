# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sidekiq_expiring_jobs"

require "minitest/autorun"

class TestCase < Minitest::Test
  def setup
    Sidekiq.redis(&:flushdb)
  end

  alias assert_not_match refute_match
end
