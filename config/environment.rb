# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])
require 'yaml'
# require 'uri'
require 'logger'

DB_CONFIG = YAML.load_file('./config/database.yml')
puts "Starting with Environment: #{ENV['RACK_ENV']}"
ActiveRecord::Base.establish_connection(DB_CONFIG[ENV['RACK_ENV']])
# require './app/controllers/application_controller'
require_all 'app'
