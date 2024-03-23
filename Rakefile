# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require_relative './config/environment'
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Run all tests, even those usually excluded.'
task all_tests: :environment do
  ENV['RUN_ALL_TESTS'] = 'true'
  Rake::Task['spec'].invoke
end
