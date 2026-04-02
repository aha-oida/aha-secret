# frozen_string_literal: true

require_relative 'database'
require 'sequel/extensions/migration'

# The 3 blank migration files deleted during the ActiveRecord→Sequel transition.
# They were no-ops consolidated into 20240322074525_create_bins.rb, but existing
# databases may still have their filenames recorded in schema_migrations.
REMOVED_MIGRATION_FILES = %w[
  20240324133511_add_random_id.rb
  20240326191856_remove_id_from_bins.rb
  20240407035007_rename_random_id_to_id.rb
].freeze

# Returns true only if the database still tracks any of the removed blank
# migration filenames — meaning allow_missing_migration_files: true is needed.
# Returns false on a fresh install (no schema_migrations table yet) or once all
# deployments have passed through the transition and the filenames are gone.
def removed_migrations_tracked?(db = DB)
  return false unless db.table_exists?(:schema_migrations)

  columns = db.schema(:schema_migrations).map(&:first)
  return false unless columns.include?(:filename)

  db[:schema_migrations].where(filename: REMOVED_MIGRATION_FILES).any?
end

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

# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
# This is a one-time migration utility to convert from ActiveRecord to Sequel.
# The complexity is acceptable for a migration utility that will be removed in the future.
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
    elsif verbose
      warn "  Warning: No migration file found for version #{version}"
    end
  end

  # Drop old table and rename new one
  db.drop_table(:schema_migrations)
  db.rename_table(:schema_migrations_new, :schema_migrations)

  puts 'Conversion complete!' if verbose
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

def check_pending_migrations!
  # Convert ActiveRecord schema_migrations if needed (silent mode for startup)
  convert_activerecord_schema_migrations_to_sequel!(DB, verbose: false)

  # Only skip the missing-file safety check when the DB still tracks the removed
  # blank migration filenames (see REMOVED_MIGRATION_FILES). This ensures the
  # safety net is preserved for fully-migrated databases and fresh installs.
  Sequel::TimestampMigrator.check_current(DB, 'db/migrate', allow_missing_migration_files: removed_migrations_tracked?)
rescue Sequel::Migrator::NotCurrentError
  warn_pending_migrations
end
