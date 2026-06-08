# frozen_string_literal: true

require "rspec/active_job"

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.include(RSpec::ActiveJob)
  config.include(ActiveJob::TestHelper)

  config.after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end
end
