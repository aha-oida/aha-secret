ENV['RACK_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])
require 'yaml'
#require 'uri'
require 'logger'

DB_CONFIG = YAML.load_file( './config/database.yml' )
ActiveRecord::Base.establish_connection( DB_CONFIG[ENV['RACK_ENV']] ) ## note: assumes 'development'


# require './app/controllers/application_controller'
require_all 'app'
