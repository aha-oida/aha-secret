# frozen_string_literal: true

require 'bundler/setup'
require 'require_all'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/config_file'
require 'sinatra/activerecord'
require 'yaml'
require 'logger'
require 'i18n'
require 'i18n/backend/fallbacks'

# TODO: do we really need a "require all" gem for 1 controller?
require_all 'app'
