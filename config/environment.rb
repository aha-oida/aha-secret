# frozen_string_literal: true

require 'bundler/setup'
require 'require_all'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/activerecord'
require 'yaml'
require 'logger'
# TODO: do we really need a "require all" gem for 1 controller?
require_all 'app'
