Resque.inline = ENV.key?('INLINE_JOBS')
Resque.configure do |config|
  config.redis = ENV['REDISCLOUD_URL'] if ENV['REDISCLOUD_URL']
end
