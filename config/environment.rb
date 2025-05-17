# frozen_string_literal: true

require 'bundler/setup'
require 'require_all'
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

# TODO: do we really need a "require all" gem for 1 controller?
require_all 'app'
