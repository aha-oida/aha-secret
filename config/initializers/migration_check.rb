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

def convert_activerecord_schema_migrations_to_sequel!(db = DB, verbose: false)
  # Skip if schema_migrations table doesn't exist (fresh install)
  return unless db.table_exists?(:schema_migrations)

  columns = db.schema(:schema_migrations).map(&:first)

  # Skip if already in Sequel format (has filename column)
  return if columns.include?(:filename)

  # Check if it's in ActiveRecord format (has version column)
  return unless columns.include?(:version)

  puts 'Detected ActiveRecord schema_migrations table, converting to Sequel format...' if verbose

  # Get all migration files from filesystem
  migrations_dir = File.expand_path('../../db/migrate', __dir__)
  migration_files = Dir.glob("#{migrations_dir}/*.rb").map { |f| File.basename(f) }

  # Create new table with Sequel structure
  db.create_table(:schema_migrations_new) do
    String :filename, primary_key: true, null: false
  end

  # Migrate data: map version numbers to actual filenames
  db[:schema_migrations].select(:version).each do |row|
    version = row[:version].to_s
    # Find the migration file that starts with this version
    filename = migration_files.find { |f| f.start_with?(version) }

    # Insert into new table if we found a matching file
    if filename
      db[:schema_migrations_new].insert(filename: filename)
      puts "  Migrated: #{version} -> #{filename}" if verbose
    else
      warn "  Warning: No migration file found for version #{version}" if verbose
    end
  end

  # Drop old table and rename new one
  db.drop_table(:schema_migrations)
  db.rename_table(:schema_migrations_new, :schema_migrations)

  puts 'Conversion complete!' if verbose
end

def check_pending_migrations!
  # Convert ActiveRecord schema_migrations if needed (silent mode for startup)
  convert_activerecord_schema_migrations_to_sequel!(DB, verbose: false)

  Sequel::TimestampMigrator.check_current(DB, 'db/migrate')
rescue Sequel::Migrator::NotCurrentError
  warn_pending_migrations
end
