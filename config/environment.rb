# frozen_string_literal: true

require_relative '../app/lib/app_config'
AppConfig.load!

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'yaml'
require 'logger'
require 'i18n'
require 'i18n/backend/fallbacks'

require_relative '../app/helpers/helpers'
require_relative '../app/controllers/application_controller'
require_relative '../app/models/bin'
