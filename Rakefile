# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require_relative 'config/environment'
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

task default: :spec

desc 'Starts the thin web server through rackup.'
task :serve do
  `bundle exec rackup -p 9292`
end

desc 'Starts the puma web server with rerun'
task :rerun do
  `bundle exec rerun --dir app,config,public -- rackup  --port=9292`
end

RSpec::Core::RakeTask.new(:spec)

desc 'Run all tests, even those usually excluded.'
task all_tests: :environment do
  ENV['RUN_ALL_TESTS'] = 'true'
  Rake::Task['spec'].invoke
end

# does not work - but the executed cmd manually does
# desc 'Simulate autotest with rerun.'
# task :autotest do
#   ENV['RUN_ALL_TESTS'] = 'true'
#   `bundle exec rerun -cx rspec`
# end

desc 'Cleanup expired bins.'
task cleanup: :environment do
  Bin.cleanup
end

desc 'Prepare db and serve.'
task :migrateserv do
  Rake::Task['db:migrate'].invoke
  Rake::Task['serve'].invoke
end

task :after_migration_hook do
  ENV['SCHEMA_FORMAT'] = 'sql'
  Rake::Task['db:schema:dump'].invoke
end

Rake::Task['db:migrate'].enhance [:after_migration_hook]
