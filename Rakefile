# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require_relative './config/environment'
require 'sinatra/activerecord/rake'

desc 'Starts the thin web server through rackup.'
task :serve do
  `bundle exec rackup -p 9292`
end
