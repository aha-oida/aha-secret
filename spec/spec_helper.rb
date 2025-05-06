# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
if ENV['COVERAGE']
  SimpleCov.start do
    add_filter(/^\/spec\//) # For RSpec, use `test` for MiniTest
    enable_coverage(:branch)
  end
end

ENV['RACK_ENV'] = 'test'

require_relative '../config/environment'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'database_cleaner'
require 'capybara-playwright-driver'


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
    Capybara::Playwright::Driver.new(app,
    # browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
    browser_type: :chromium,
    headless: true)
  end
  Capybara.default_max_wait_time = 15
  Capybara.default_driver = :playwright
  Capybara.save_path = 'tmp/capybara'

  Capybara.current_driver = :playwright

  unless ENV['SHOW_BROWSER']
    original_stderr = $stderr
    original_stdout = $stdout
    config.before(:all) do
      # Redirect stderr and stdout
      $stderr = File.open(File::NULL, "w")
      $stdout = File.open(File::NULL, "w")
    end
    config.after(:all) do
      $stderr = original_stderr
      $stdout = original_stdout
    end
  end
end

def app
  Rack::Builder.parse_file('config.ru')
end

Capybara.app = app

Rack::Attack.enabled = false
