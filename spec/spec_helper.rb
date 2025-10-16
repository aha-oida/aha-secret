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

# Ensure MEMCACHE is set for rate limiting in test/CI
env_memcache = ENV['MEMCACHE'] || 'localhost:11211'
ENV['MEMCACHE'] = env_memcache

# Ensure SKIP_SCHEDULER is set to 'true' for all tests to avoid running Rufus::Scheduler
ENV['SKIP_SCHEDULER'] = 'true'

require_relative '../config/environment'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'database_cleaner'
require 'capybara/cuprite'

# puts "Running with cuprite driver"
# puts "PATH: #{ENV['PATH']}"
# puts "which chromium: #{`which chromium`.strip}"
# puts "which chromium-browser: #{`which chromium-browser`.strip}"
# puts "which google-chrome: #{`which google-chrome`.strip}"

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

  Capybara.javascript_driver = :cuprite
  Capybara.default_max_wait_time = 5
  Capybara.disable_animation = true
  Capybara.register_driver(:cuprite) do |app|
    Capybara::Cuprite::Driver.new(app,
      js_errors: true,
      window_size: [1200, 800],
      browser_options: {},
      headless: (ENV['SHOW_BROWSER'] ? false : true),
      # headless: true,
      timeout: 15,
      # inspector: true
    )
  end

  config.filter_gems_from_backtrace("capybara", "cuprite", "ferrum")

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

# fix Capybara::Screenshot path with sinatra
# see https://github.com/mattheworiordan/capybara-screenshot/issues/177#issuecomment-264787232
# root = File.expand_path(File.join(File.dirname(__FILE__), "../tmp"))
# Capybara::Screenshot.instance_variable_set :@capybara_root, root

def app
  Rack::Builder.parse_file('config.ru')
end

Capybara.app = app

# Disable Rack::Attack by default in test
default_attack_enabled = false
Rack::Attack.enabled = default_attack_enabled
