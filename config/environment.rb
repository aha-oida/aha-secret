# frozen_string_literal: true

environment = ENV['RACK_ENV'] || 'development'

require 'bundler/setup'
# Bundler.require(:default, environment)
require 'active_record'
require 'require_all'
require 'sinatra/base'
require 'sinatra/config_file'
require 'yaml'
# require 'uri'
require 'logger'

DB_CONFIG = YAML.load_file('./config/database.yml')
puts "Starting with Environment: #{environment}"
ActiveRecord::Base.establish_connection(DB_CONFIG[environment])
# require './app/controllers/application_controller'
require_all 'app'
