# frozen_string_literal: true

require_relative '../app/lib/app_config'
# AppConfig.load! is no longer called here to allow lazy loading and test stubs

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'sinatra/config_file'
require 'sequel'
require 'yaml'
require 'logger'
require 'i18n'
require 'i18n/backend/fallbacks'

# Database connection setup for Sequel
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/development.sqlite3')

require_relative '../app/helpers/helpers'
require_relative '../app/controllers/application_controller'
require_relative '../app/models/bin'
