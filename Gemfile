# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activerecord', '~> 8.1.0', require: 'active_record'
gem 'dalli', '>= 3.2'
gem 'debug', '>= 1.0.0'
gem 'erubis', '~> 2.7'
gem 'i18n', '~> 1.14.7'
gem 'puma', '~> 7.1'
gem 'rack-attack', '~> 6.8'
gem 'rackup', '~> 2.2'
gem 'rake', '~> 13.3'
gem 'rspec', '~> 3.13'
gem 'rufus-scheduler', '~> 3.9'
gem 'sinatra', '~> 4.2'
gem 'sinatra-activerecord', require: 'sinatra/activerecord'
gem 'sprockets-helpers'

github 'sinatra/sinatra' do
  gem 'sinatra-contrib'
end
gem 'sqlite3', '~> 2.7'

group :development do
  gem 'brakeman', '~> 7.1.1'
  gem 'i18n-tasks', '~> 1.0.15'
  gem 'overcommit', '~> 0.68'
  gem 'rerun', '~> 0.14.0'
  gem 'rubocop', '~> 1.81'
end

group :test do
  gem 'capybara', '~> 3.40.0'
  gem 'cuprite'
  gem 'database_cleaner', '~> 2.1.0'
  gem 'faker', '~> 3.5.2'
  gem 'rack-test', '~> 2.2'
  gem 'simplecov'
  gem 'simplecov-lcov'
  gem 'timecop'
  gem 'undercover', '~> 0.8.1'
end
