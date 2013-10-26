Sidekiq.configure_server do |config|
  config.redis = { :url => 'unix:/opt/local/redis/redis.sock', :namespace => 'sidekiq_yfplatform' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'unix:/opt/local/redis/redis.sock', :namespace => 'sidekiq_yfplatform' }
end
