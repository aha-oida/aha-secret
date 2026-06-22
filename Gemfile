# frozen_string_literal: true

source 'https://rubygems.org'

gem 'dalli', '>= 3.2'
gem 'i18n', '~> 1.14.8'
gem 'puma', '~> 8.0'
gem 'rack-attack', '~> 6.8'
gem 'rackup', '~> 2.3'
gem 'rake', '~> 13.4'
gem 'rufus-scheduler', '~> 3.9'
gem 'sequel', '~> 5.77'
gem 'sinatra', '~> 4.2'
gem 'sprockets-helpers'

github 'sinatra/sinatra' do
  gem 'sinatra-contrib'
end
gem 'sqlite3', '~> 2.9'

group :development do
  gem 'brakeman', '~> 8.0.4'
  gem 'debug', '>= 1.0.0'
  gem 'overcommit', '~> 0.70'
  gem 'rerun', '~> 0.14.0'
  gem 'rubocop', '~> 1.88'
end

group :development, :test do
  gem 'rspec', '~> 3.13'
end

group :test do
  gem 'capybara', '~> 3.40.0'
  gem 'cuprite'
  gem 'database_cleaner-sequel'
  gem 'faker', '~> 3.8.0'
  gem 'rack-test', '~> 2.2'
  gem 'simplecov'
  gem 'simplecov-lcov'
  gem 'timecop'
end
