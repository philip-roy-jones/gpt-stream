class SidekiqJob
  include Sidekiq::Job   # (newer API, equivalent to Sidekiq::Worker)

  sidekiq_options queue: :default
end