require 'resque/failure/airbrake'
Resque::Failure.backend = Resque::Failure::Airbrake
ActiveJob::Base.queue_adapter = :resque
Resque.inline = ENV['INLINE_JOBS'] == 'true'
Resque.redis = ENV['REDISCLOUD_URL'] if ENV['REDISCLOUD_URL']
Resque.logger = MonoLogger.new(STDOUT) unless Rails.env.test?
Resque.logger.level = MonoLogger::INFO
