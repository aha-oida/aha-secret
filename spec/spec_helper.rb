# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../config/environment'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'database_cleaner'
require 'capybara-playwright-driver'
require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  # add_filter(/^\/spec\//) # For RSpec, use `test` for MiniTest
  enable_coverage(:branch)
end

ActiveRecord::Base.logger = nil

class CapybaraNullDriver < Capybara::Driver::Base
  def needs_server?
    true
  end
end

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

  Capybara.register_driver(:playwright) do |app|
    # Capybara::Playwright::Driver.new(app, browser_type: :firefox, headless: false)
    Capybara::Playwright::Driver.new(app,
    browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
    headless: (false unless ENV["CI"] || ENV["PLAYWRIGHT_HEADLESS"]))
  end
  Capybara.default_max_wait_time = 15
  Capybara.default_driver = :playwright
  Capybara.save_path = 'tmp/capybara'

  Capybara.current_driver = :playwright


end

def app
  Rack::Builder.parse_file('config.ru')
end

Capybara.app = app

Rack::Attack.enabled = false
