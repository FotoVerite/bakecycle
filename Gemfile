source 'https://rubygems.org'

ruby '2.1.5'

gem 'rails', '4.1.1'
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
gem 'devise'
gem 'airbrake'
gem 'draper', '~> 1.3'
gem 'unicorn', require: false
gem 'jquery-timepicker-rails'
gem 'geocoder'

group :development do
  gem 'spring'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'pry'
  gem 'pry-byebug'
  gem 'shoulda-matchers', require: false
  gem 'cucumber-rails', require: false
  gem 'rubocop'
  gem 'guard-rails'
  gem 'guard-livereload'
  gem 'rack-livereload'
  gem 'guard-bundler'
end

group :test do
  gem 'webmock'
end

group :test, :development, :staging do
  gem 'factory_girl_rails'
  gem 'faker'
end

group :production, :staging do
  gem "rails_12factor"
end
