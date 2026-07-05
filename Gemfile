# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.1"

gem "aws-sdk-s3"
gem "caxlsx"
gem "caxlsx_rails"
gem "chronic"
gem "dartsass-rails"
gem "devise"
gem "devise_invitable"
gem "dotenv-rails"
gem "draper"
gem "geocoder"
gem "jquery-rails"
gem "jquery-timepicker-rails"
gem "jquery-ui-sass-rails"
gem "jsbundling-rails"
gem "jwt"
gem "kt-paperclip", "~> 7.0"
gem "mission_control-jobs"
gem "paper_trail"
gem "pg"
gem "prawn"
gem "prawn-table"
gem "propshaft"
gem "pundit"
gem "rails", "~> 8.0"
gem "riif"
gem "rubyzip", ">= 2.0"
gem "simple_form"
gem "solid_cable"
gem "solid_queue"
gem "stripe", "< 6"
gem "unitwise", "~>2.0.0", require: "unitwise"
gem "will_paginate"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano"
  gem "capistrano3-puma"
  gem "capistrano-bundler", require: false
  gem "capistrano-npm"
  gem "capistrano-rails", require: false
  gem "capistrano-solid_queue", require: false
  gem "foreman", require: false
  gem "letter_opener"
  gem "rails-erd", require: false
  gem "web-console", ">= 4.1.0"
end

group :test, :development do
  gem "brakeman", require: false
  gem "bullet"
  gem "pry"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "shoulda-matchers", require: false
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "database_cleaner-active_record"
  gem "pdf-reader", require: false
  gem "rspec-activejob"
  gem "simplecov", require: false
  gem "stripe-ruby-mock", require: "stripe_mock"
  gem "timecop"
  gem "webmock", require: false
end

group :test, :development, :staging do
  gem "factory_bot_rails"
  gem "faker"
end

group :production, :staging, :test do
  gem "puma"
  gem "sentry-rails"
  gem "sentry-ruby"
end

group :production, :staging do
  # Honeycomb's model is query-first, not trace-first: wide events with full
  # request context, queried/sliced ad hoc after the fact (BubbleUp), not a
  # pre-curated set of "interesting" spans decided in advance. That only
  # works if the data is actually wide, so use_all instead of hand-picking
  # instrumentation libraries.
  gem "opentelemetry-sdk"
  gem "opentelemetry-exporter-otlp"
  gem "opentelemetry-instrumentation-all"
end
