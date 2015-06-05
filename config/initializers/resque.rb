Resque.inline = ENV.key?('INLINE_JOBS')
Resque.redis = ENV['REDISCLOUD_URL'] if ENV['REDISCLOUD_URL']
