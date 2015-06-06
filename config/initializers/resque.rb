ActiveJob::Base.queue_adapter = :resque
Resque.inline = ENV['INLINE_JOBS'] == 'true'
Resque.redis = ENV['REDISCLOUD_URL'] if ENV['REDISCLOUD_URL']
