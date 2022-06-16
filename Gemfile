source "https://rubygems.org"

ruby "2.5.1"
gem "active_model_serializers", "~> 0.9.3"
gem "airbrake"
gem "aws-sdk", "< 2.0"
gem "axlsx_rails"
gem "axlsx", "2.0.1"
gem "browserify-rails", "4.3.0"
gem "chronic"
gem "devise"
gem "devise-async", git: "https://github.com/klacointe/devise-async.git", branch: "devise4"
gem "devise_invitable"
gem "draper"
gem "foundation-icons-sass-rails"
gem "foundation-rails", "~>5.5.0.0"
gem "geocoder"
gem "jbuilder", "~> 2.0"
gem "jquery-rails"
gem "jquery-timepicker-rails"
gem "jquery-ui-sass-rails"
gem "memoist"
gem "paper_trail"
gem "paperclip", "~> 4.2"
gem "pg"
gem "prawn"
gem "prawn-table"
gem "pundit"
gem "rails", "5.1.7"
gem "redis", "3.3.5"
gem "resque", require: "resque/server"
gem "rubyzip", "1.0.0"
gem "sass-rails"
gem "simple_form"
gem "stripe"
gem "uglifier"
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
  gem "spring"
  gem "spring-commands-rspec"
  gem "web-console", "~> 2.0"
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
  gem "rspec-activejob"
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
