source 'https://rubygems.org'

ruby '2.2.2'

gem 'active_model_serializers'
gem 'airbrake'
gem 'aws-sdk', '< 2.0'
gem 'bower-rails'
gem 'cancancan', '~> 1.10'
gem 'chronic'
gem 'coffee-rails', '~> 4.0.0'
gem 'devise'
gem 'draper'
gem 'font-awesome-rails'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails'
gem 'geocoder'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'jquery-timepicker-rails'
gem 'jquery-ui-sass-rails'
gem 'paperclip', '~> 4.2'
gem 'pg'
gem 'prawn'
gem 'prawn-table'
gem 'rails', '4.2.1'
gem 'sass-rails'
gem 'simple_form'
gem 'skylight'
gem 'uglifier', '>= 1.3.0'
gem 'unicorn', require: false
gem 'unitwise'
gem 'will_paginate', '~> 3.0.6'

# deployment
gem 'httparty', require: false
gem 'netrc', require: false
gem 'rendezvous', require: false

# legacy import
gem 'mysql2', require: false

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test, :development do
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'bundler-audit', require: false
  gem 'cucumber-rails', require: false
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-rails'
  gem 'immigrant'
  gem 'pry'
  gem 'rack-livereload'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'webmock', require: false
end

group :test, :development, :staging do
  gem 'factory_girl_rails'
  gem 'faker'
end

group :production, :staging do
  gem 'rails_12factor'
end
