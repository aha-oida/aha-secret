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

# Ensure AHA_SECRET_MEMCACHE_URL is set for rate limiting in test/CI
env_memcache = ENV['AHA_SECRET_MEMCACHE_URL'] || 'localhost:11211'
ENV['AHA_SECRET_MEMCACHE_URL'] = env_memcache

# Ensure SKIP_SCHEDULER is set to 'true' for all tests to avoid running Rufus::Scheduler
ENV['SKIP_SCHEDULER'] = 'true'

# Set up database and run migrations BEFORE loading models
require 'sequel'
require 'sequel/extensions/migration'
require_relative '../config/initializers/migration_check'

# DB is already connected via database.rb (required by migration_check.rb)
# Convert ActiveRecord schema_migrations if needed, then run migrations
convert_activerecord_schema_migrations_to_sequel!(DB, verbose: false)
# Conditionalize the missing-file allowance - see REMOVED_MIGRATION_FILES in migration_check.rb.
Sequel::TimestampMigrator.run(DB, 'db/migrate', allow_missing_migration_files: removed_migrations_tracked?)

# Now load the rest of the application
require_relative '../config/environment'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/cuprite'
require 'database_cleaner/sequel'
require 'fileutils'

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
  config.filter_run_excluding screenshots: true unless ENV['RUN_MANUAL_SCREENSHOTS'] == 'true'
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
  screenshot_dir = ENV['AHA_SECRET_SCREENSHOT_DIR']
  Capybara.save_path =
    if screenshot_dir && !screenshot_dir.empty?
      File.expand_path(screenshot_dir)
    else
      File.expand_path('../tmp/capybara', __dir__)
    end
  FileUtils.mkdir_p(Capybara.save_path)
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

  config.after(:each, type: :feature) do |example|
    next unless example.exception

    timestamp = Time.now.utc.strftime('%Y%m%d-%H%M%S-%L')
    safe_name = example.full_description
      .downcase
      .gsub(/[^a-z0-9]+/, '-')
      .gsub(/\A-|\z/, '')
      .slice(0, 120)

    screenshot_path = File.join(Capybara.save_path, "failure-#{safe_name}-p#{Process.pid}-#{timestamp}.png")
    page.save_screenshot(screenshot_path, full: true)
  rescue StandardError => e
    warn "Failed to save screenshot for '#{example.full_description}': #{e.message}"
  end

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
