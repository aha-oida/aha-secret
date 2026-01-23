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
ENV['DATABASE_URL'] ||= 'sqlite://db/database/test.sqlite3'

# Ensure MEMCACHE is set for rate limiting in test/CI
env_memcache = ENV['MEMCACHE'] || 'localhost:11211'
ENV['MEMCACHE'] = env_memcache

# Ensure SKIP_SCHEDULER is set to 'true' for all tests to avoid running Rufus::Scheduler
ENV['SKIP_SCHEDULER'] = 'true'

# Set up database and run migrations BEFORE loading models
require 'sequel'
require 'sequel/extensions/migration'
require_relative '../config/initializers/migration_check'

test_db = Sequel.connect(ENV['DATABASE_URL'])

# Convert ActiveRecord schema_migrations if needed
convert_activerecord_schema_migrations_to_sequel!(test_db, verbose: false)

Sequel::TimestampMigrator.run(test_db, 'db/migrate')
test_db.disconnect

# Now load the application (which will reconnect to the DB)
require_relative '../config/environment'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/cuprite'
require 'database_cleaner/sequel'

# puts "Running with cuprite driver"
# puts "PATH: #{ENV['PATH']}"
# puts "which chromium: #{`which chromium`.strip}"
# puts "which chromium-browser: #{`which chromium-browser`.strip}"
# puts "which google-chrome: #{`which google-chrome`.strip}"

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

  # Configure DatabaseCleaner for Sequel
  config.before(:suite) do
    DatabaseCleaner[:sequel, db: DB].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner[:sequel, db: DB].start
  end

  config.after(:each) do
    DatabaseCleaner[:sequel, db: DB].clean
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
      process_timeout: 20,
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
