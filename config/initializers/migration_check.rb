# frozen_string_literal: true

require_relative 'database'
require 'sequel/extensions/migration'

def warn_pending_migrations
  warn "\n#{'=' * 80}"
  warn 'ERROR: Database migrations are pending!'
  warn '=' * 80
  warn 'Your database schema is not up to date.'
  warn 'Please run the following command to apply pending migrations:'
  warn ''
  warn '  bundle exec rake db:migrate'
  warn ''
  warn "#{'=' * 80}\n"
  exit 1
end

def ensure_schema_migrations_filename_column!
  # Check if schema_migrations table exists first
  return unless DB.table_exists?(:schema_migrations)

  columns = DB.schema(:schema_migrations).map(&:first)
  return if columns.include?(:filename)

  DB.alter_table(:schema_migrations) { add_column :filename, String }
end

def populate_schema_migrations_filenames!
  # Check if schema_migrations table exists first
  return unless DB.table_exists?(:schema_migrations)

  migrations_dir = File.expand_path('../../db/migrate', __dir__)
  DB[:schema_migrations].where(filename: nil).each do |row|
    version = row[:version].to_s
    file = Dir.glob("#{migrations_dir}/#{version}_*.rb").first
    if file
      filename = File.basename(file)
      DB[:schema_migrations].where(version: row[:version]).update(filename: filename)
    end
  end
end

def check_pending_migrations!
  ensure_schema_migrations_filename_column!
  populate_schema_migrations_filenames!
  Sequel::TimestampMigrator.check_current(DB, 'db/migrate')
rescue Sequel::Migrator::NotCurrentError
  warn_pending_migrations
end

# Only check for pending migrations unless running tests or rake tasks
unless (defined?(running_tests) && running_tests) || ENV['RUNNING_RAKE']
  check_pending_migrations!
end
