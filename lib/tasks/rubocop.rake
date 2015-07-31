if Rails.env.development? || Rails.env.test?
  require "rubocop/rake_task"
  task default: :rubocop
  RuboCop::RakeTask.new
end
