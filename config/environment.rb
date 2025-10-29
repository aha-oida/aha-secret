# frozen_string_literal: true

require_relative '../app/lib/app_config'
# AppConfig.load! is no longer called here to allow lazy loading and test stubs

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/config_file'
require 'sequel'
require 'yaml'
require 'logger'
require 'i18n'
require 'i18n/backend/fallbacks'

# Database connection setup for Sequel
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/development.sqlite3')
DB.loggers << Logger.new($stdout) if ENV['RACK_ENV'] == 'development'

# Determine if we're running in a context where we should skip migration checks and model loading
running_rake = defined?(Rake) && Rake.application.top_level_tasks.any?
running_db_task = running_rake && Rake.application.top_level_tasks.any? { |task| task.start_with?('db:') }
running_tests = ENV['RACK_ENV'] == 'test'

# Check for pending migrations before loading models
require 'sequel/extensions/migration'
if !running_tests && !running_rake
  begin
    Sequel::Migrator.check_current(DB, 'db/migrate')
  rescue Sequel::Migrator::NotCurrentError
    warn "\n" + ('=' * 80)
    warn 'ERROR: Database migrations are pending!'
    warn '=' * 80
    warn 'Your database schema is not up to date.'
    warn 'Please run the following command to apply pending migrations:'
    warn ''
    warn '  bundle exec rake db:migrate'
    warn ''
    warn '=' * 80 + "\n"
    exit 1
  end
end

# Load application code unless running db rake tasks (which may run before tables exist)
unless running_db_task
  require_relative '../app/helpers/helpers'
  require_relative '../app/controllers/application_controller'
  require_relative '../app/models/bin'
end
