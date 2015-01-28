source 'https://rubygems.org'

ruby '2.2.0'

gem 'rails', '4.1.9'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jquery-ui-sass-rails'
gem 'jbuilder', '~> 2.0'
gem 'bower-rails'
gem 'foundation-rails'
gem 'foundation-icons-sass-rails'
gem 'simple_form'
gem 'devise'
gem 'airbrake'
gem 'draper', '~> 1.3'
gem 'unicorn', require: false
gem 'jquery-timepicker-rails'
gem 'geocoder'
gem 'chronic'

group :development do
  gem 'spring'
  gem 'quiet_assets'
end

group :test, :development do
  gem 'brakeman', require: false
  gem 'cucumber-rails', require: false
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rack-livereload'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'webmock'
end

group :test, :development, :staging do
  gem 'factory_girl_rails'
  gem 'faker'
end

group :production, :staging do
  gem "rails_12factor"
end
