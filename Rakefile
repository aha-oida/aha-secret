# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require_relative './config/environment'
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

desc 'Starts the thin web server through rackup.'
task :serve do
  `bundle exec rackup -p 9292`
end

RSpec::Core::RakeTask.new(:spec)

desc 'Run all tests, even those usually excluded.'
task all_tests: :environment do
  ENV['RUN_ALL_TESTS'] = 'true'
  Rake::Task['spec'].invoke
end
