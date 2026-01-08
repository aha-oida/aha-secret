# frozen_string_literal: true

Sequel.migration do
  up do
    # Migrate from ActiveRecord's schema_migrations to Sequel's schema_migrations
    # ActiveRecord uses 'version' column, Sequel uses 'filename' column

    # Check if we have the old ActiveRecord structure (version column exists)
    if self[:schema_migrations].columns.include?(:version)
      # Create a temporary table with Sequel structure
      create_table(:schema_migrations_new) do
        String :filename, primary_key: true, null: false
      end

      # Migrate data: map version numbers to actual filenames
      # Get all migration files from the filesystem
      migration_files = Dir.glob('db/migrate/*.rb').map { |f| File.basename(f) }

      # For each version in the old table, find the corresponding filename
      from(:schema_migrations).select(:version).each do |row|
        version = row[:version]
        # Find the migration file that starts with this version
        filename = migration_files.find { |f| f.start_with?(version) }

        # Insert into new table if we found a matching file
        if filename
          self[:schema_migrations_new].insert(filename: filename)
        end
      end

      # Drop old table and rename new one
      drop_table(:schema_migrations)
      rename_table(:schema_migrations_new, :schema_migrations)
    end
  end

  down do
    # Reverse migration: convert Sequel schema_migrations back to ActiveRecord format
    if self[:schema_migrations].columns.include?(:filename)
      create_table(:schema_migrations_new) do
        String :version, primary_key: true, null: false
      end

      # Extract version from filename (first 14 digits)
      from(:schema_migrations).select(:filename).each do |row|
        version = row[:filename].match(/^(\d+)/)[1]
        self[:schema_migrations_new].insert(version: version)
      end

      drop_table(:schema_migrations)
      rename_table(:schema_migrations_new, :schema_migrations)
    end
  end
end
