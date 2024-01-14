# frozen_string_literal: true

module SidekiqExpiringJobs
  module Middleware
    class Client
      def call(_worker_class, job, _queue, _redis_pool)
        if (expires_in = job.delete("expires_in"))
          expires_in = expires_in.to_f
          raise ArgumentError, ":expires_in must be a relative time, not absolute time" if expires_in > 1_000_000_000

          at = job["at"] || job["created_at"]
          job["expires_at"] = at + expires_in
        end
        yield
      end
    end

    class Server
      def call(_worker, job, _queue)
        if (expires_at = job["expires_at"])
          if expires_at >= Time.now.to_f
            yield
          else
            Sidekiq.logger.info("[SidekiqExpiringJobs] Expired #{job['class']} job (jid=#{job['jid']}) is skipped")
            SidekiqExpiringJobs.expiration_callback&.call(job)
          end
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
