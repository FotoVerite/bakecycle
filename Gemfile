source "https://rubygems.org"

ruby "2.2.2"

gem "active_model_serializers", "~>0.9.3"
gem "airbrake"
gem "aws-sdk", "< 2.0"
gem "browserify-rails"
gem "chronic"
gem "coffee-rails", "~> 4.0.0"
gem "devise", "~> 3.5.6"
gem "devise-async"
gem "devise_invitable"
gem "draper"
gem "foundation-icons-sass-rails"
gem "foundation-rails"
gem "geocoder"
gem "jbuilder", "~> 2.0"
gem "jquery-rails"
gem "jquery-timepicker-rails"
gem "jquery-ui-sass-rails"
gem "memoist"
gem "paperclip", "~> 4.2"
gem "pg"
gem "prawn"
gem "prawn-table"
gem "pundit"
gem "rails", "4.2.6"
gem "stripe"
gem "resque", require: "resque/server"
gem "riif"
gem "sass-rails"
gem "simple_form"
gem "uglifier", ">= 1.3.0"
gem "unicorn", require: false
gem "unitwise-193", require: "unitwise"
gem "will_paginate", "~> 3.0.6"
gem "wizarddev-heroku"

# legacy import
gem "mysql2", require: false

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
  gem "quiet_assets"
  gem "spring"
  gem "spring-commands-rspec"
  gem "web-console", "~> 2.0"
  gem "foreman", require: false
end

group :test, :development do
  gem "brakeman", require: false
  gem "bullet"
  gem "bundler-audit", require: false
  gem "cucumber-rails", require: false
  gem "guard-bundler"
  gem "guard-livereload"
  gem "guard-rails"
  gem "immigrant"
  gem "pry"
  gem "rack-livereload"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false
  gem "shoulda-matchers", require: false
end

group :test do
  gem "capybara-email"
  gem "capybara-screenshot"
  gem "capybara-webkit"
  gem "database_cleaner"
  gem "launchy"
  gem "rspec-activejob"
  gem "selenium-webdriver"
  gem "stripe-ruby-mock", "~> 2.1.1", require: false
  gem "test_after_commit"
  gem "webmock", require: false
end

group :test, :development, :staging do
  gem "factory_girl_rails"
  gem "faker"
end

group :production, :staging do
  gem "rails_12factor"
  gem "newrelic_rpm"
end
