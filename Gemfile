source "https://rubygems.org"

ruby "3.1.1"

gem "active_model_serializers", "~> 0.10.0"
gem "airbrake"
gem "caxlsx_rails"
gem "caxlsx"
gem "jsbundling-rails"
gem "chronic"
gem "devise"
gem "devise_invitable"
gem "draper"
gem "geocoder"
gem "jbuilder", "~> 2.0"
gem "jquery-rails"
gem "jquery-timepicker-rails"
gem "jquery-ui-sass-rails"
gem "kt-paperclip", "~> 7.0"
gem "memoist"
gem "paper_trail"
gem "pg"
gem "prawn"
gem "prawn-table"
gem "pundit"
gem "rails", "~> 6.1.0"
gem "redis", "~> 4.0"
gem "resque", "~> 2.0", require: "resque/server"
gem "rubyzip", ">= 2.0"
gem "sass-rails", ">= 6"
gem "simple_form"
gem "stripe", "< 6"
gem "unitwise", "~>2.0.0", require: "unitwise"
gem "will_paginate"
gem "rest-client"
gem "dotenv-rails"
gem "jwt"
gem "riif"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano"
  gem "capistrano-bundler", require: false
  gem "capistrano-npm"
  gem "capistrano-rails", require: false
  gem "capistrano-resque", "~> 0.2.2", require: false
  gem "capistrano3-puma"
  gem "foreman", require: false
  gem "letter_opener"
  gem "rails-erd", require: false
  gem "web-console", ">= 4.1.0"
end

group :test, :development do
  gem "brakeman", require: false
  gem "bullet"
  gem "cucumber-rails", require: false
  gem "guard-livereload"
  gem "guard-rails"
  gem "immigrant"
  gem "pry"
  gem "rack-livereload"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "shoulda-matchers", require: false
end

group :test do
  gem "capybara-email"
  gem "capybara-screenshot"
  gem "selenium-webdriver"
  gem "database_cleaner"
  gem "launchy"
  gem "pdf-reader", require: false
  gem "rspec-activejob"
  gem "simplecov", require: false
  gem "timecop"
  gem "stripe-ruby-mock", :require => "stripe_mock"
  gem "webmock", require: false
end

group :test, :development, :staging do
  gem "factory_bot_rails"
  gem "faker"
end

group :production, :staging, :test do
  gem "newrelic_rpm"
  gem "puma"
end
