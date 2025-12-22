# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'
ENV['RUNNING_RAKE'] = 'true'

require_relative 'config/environment'
require 'rspec/core/rake_task'
require 'sequel'
require 'sequel/extensions/migration'

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

desc 'Load the application environment'
task :environment do
  # Environment is already loaded via require_relative 'config/environment' at the top
  # This task exists for compatibility with tasks that depend on :environment
end

desc 'Run all tests, even those usually excluded.'
task all_tests: :environment do
  ENV['RUN_ALL_TESTS'] = 'true'
  Rake::Task['spec'].invoke
end

desc 'Cleanup expired bins.'
task cleanup: :environment do
  Bin.cleanup!
end

desc 'Prepare db and serve.'
task :migrateserv do
  Rake::Task['db:migrate'].invoke
  Rake::Task['serve'].invoke
end

namespace :db do
  desc 'Migrate the database (Sequel, timestamp-based)'
  task :migrate do
    # Reuse the migration preparation functions from migration_check.rb
    ensure_schema_migrations_filename_column!
    populate_schema_migrations_filenames!

    Sequel::TimestampMigrator.run(DB, 'db/migrate')
    puts 'Migrations complete.'
  end

  desc 'Drop the database (deletes SQLite file)'
  task :drop do
    db_path = DB.uri.split(':///').last
    if File.exist?(db_path)
      File.delete(db_path)
      puts("Deleted #{db_path}")
    else
      puts("No database file found at #{db_path}")
    end
  end

  # useless because we have no seed data
  desc 'Seed the database'
  task :seed do
    load 'db/seeds.rb'
  end
end
