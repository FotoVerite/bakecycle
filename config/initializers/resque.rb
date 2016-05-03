require "resque/failure/multiple"
require "resque/failure/airbrake"
require "resque/failure/redis"

Resque::Failure::Multiple.classes = [
  Resque::Failure::Redis,
  Resque::Failure::Airbrake
]
Resque::Failure.backend = Resque::Failure::Multiple
ActiveJob::Base.queue_adapter = :resque
Resque.inline = ENV["INLINE_JOBS"] == "true"
Resque.redis = ENV["REDIS_URL"] if ENV["REDIS_URL"]
Resque.logger = MonoLogger.new(STDOUT) unless Rails.env.test?
Resque.logger.level = MonoLogger::INFO
