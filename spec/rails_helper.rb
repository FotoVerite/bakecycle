# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "shoulda/matchers"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

if Bullet.enable?
  RSpec.configure do |config|
    config.before(:each) { Bullet.start_request }
    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  # Turbo::Broadcastable::TestHelper's assert_turbo_stream_broadcasts uses Minitest
  # assertions (assert_not_empty) that aren't available in plain RSpec example
  # groups, so specs use its lower-level capture_turbo_stream_broadcasts/broadcasts
  # methods directly with normal RSpec `expect` assertions instead.
  config.include ActionCable::TestHelper, type: :job
  config.include Turbo::Broadcastable::TestHelper, type: :job

  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  # System specs (JS/browser) use truncation so the Puma server thread can see
  # test data. All other specs stay on the fast transaction strategy.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    strategy = example.metadata[:type] == :system ? :truncation : :transaction
    DatabaseCleaner.strategy = strategy
    DatabaseCleaner.cleaning { example.run }
  end

  config.infer_spec_type_from_file_location!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end
