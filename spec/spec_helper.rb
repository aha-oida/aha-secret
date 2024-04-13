# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../config/environment'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'database_cleaner'

ActiveRecord::Base.logger = nil

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  # config.filter_run :focus
  config.include Rack::Test::Methods
  config.include Capybara::DSL
  DatabaseCleaner.strategy = :truncation
  config.before do
    DatabaseCleaner.clean
  end

  config.after do
    DatabaseCleaner.clean
  end

  # config.order = 'default'
end

def app
  Rack::Builder.parse_file('config.ru')
end

Capybara.app = app
