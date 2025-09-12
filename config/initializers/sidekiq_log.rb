# USED FOR DEBUGGING IF SIDEKIQ IS POINTING TO CORRECT REDIS URL IN .env

# Also confirm the job queue Redis (separate from Action Cable) and env seen by Sidekiq
if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    Sidekiq.logger.info "[Sidekiq] ENV[REDIS_URL]=#{ENV['REDIS_URL'].inspect}"
    begin
      # Print the Redis URL Sidekiq is using for its own queue
      client = config.redis { |c| c }  # returns a Redis client
      Sidekiq.logger.info "[Sidekiq] redis client url=#{client.client.options[:url].inspect}"
    rescue => e
      Sidekiq.logger.warn "[Sidekiq] could not read redis client url: #{e.class}: #{e.message}"
    end
  end
end
