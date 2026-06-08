# frozen_string_literal: true

require "rake"

Rails.application.load_tasks

module RakeHelpers
  def rake_task(name)
    Rake::Task[name].tap(&:reenable)
  end
end

RSpec.configure do |config|
  config.include RakeHelpers, type: :task
end
