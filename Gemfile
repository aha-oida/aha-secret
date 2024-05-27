# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'dalli', '>= 3.2'
gem 'debug', '>= 1.0.0', group: :development
gem 'erubis', '~> 2.7'
gem 'puma', '~> 6.4'
gem 'rack-attack', '~> 6.7'
gem 'rackup', '~> 2.1'
gem 'rake', '~> 13.2'
gem 'require_all', '~> 3.0'
gem 'rufus-scheduler', '~> 3.9'
gem 'sinatra', '~> 4.0'
gem 'sinatra-activerecord', require: 'sinatra/activerecord'
github 'sinatra/sinatra' do
  gem 'sinatra-contrib'
end
gem 'sqlite3', '~> 1.0'

gem 'rack-test', '~> 2.1', group: :test
gem 'rspec', '~> 3.13', group: :test

group :development do
  gem 'brakeman', '~> 6.1.2'
  gem 'overcommit', '~> 0.63'
  gem 'rerun', '~> 0.14.0'
  gem 'rubocop', '~> 1.64'
end

group :development, :test do
  gem 'capybara', '~> 3.40.0'
  gem 'database_cleaner', '~> 2.0.2'
  gem 'faker', '~> 3.3.1'
end
