# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'erubis', '~> 2.7'
gem 'pry', group: :development
gem 'puma', '~> 6.4'
gem 'rackup', '~> 2.1'
gem 'rake', '~> 13.1'
gem 'require_all', '~> 3.0'
gem 'sinatra', '~> 4.0'
gem 'sinatra-activerecord', require: 'sinatra/activerecord'
gem 'sqlite3', '~> 1.0'

gem 'rack-test', '~> 2.1', group: :test
gem 'rspec', '~> 3.13', group: :test

group :development do
  gem 'brakeman', '~> 6.1.2'
  gem 'overcommit', '~> 0.63'
  gem 'rubocop', '~> 1.62'
end

group :development, :test do
  gem 'capybara', '~> 3.40.0'
  gem 'database_cleaner', '~> 2.0.2'
  gem 'faker', '~> 3.2.3'
end

gem 'rerun', '~> 0.14.0'
