# frozen_string_literal: true

# Handle ActiveRecord → Sequel schema_migrations table migration
# This runs before any other migrations to ensure the schema_migrations table
# has the correct structure for Sequel

db = Sequel::Model.db

if db.table_exists?(:schema_migrations)
  columns = db[:schema_migrations].columns

  # If we have the old ActiveRecord structure (version column), migrate to Sequel structure (filename column)
  if columns.include?(:version) && !columns.include?(:filename)
    puts 'Migrating schema_migrations table from ActiveRecord to Sequel format...'

    # Rename old table
    db.run('ALTER TABLE schema_migrations RENAME TO schema_migrations_old')

    # Create new table with Sequel structure
    db.create_table(:schema_migrations) do
      String :filename, primary_key: true, null: false
    end

    # Get migration files and map versions to filenames
    migration_files = Dir.glob(File.join(__dir__, '../../db/migrate/*.rb')).map { |f| File.basename(f) }

    db[:schema_migrations_old].select(:version).each do |row|
      filename = migration_files.find { |f| f.start_with?(row[:version]) }
      if filename
        db[:schema_migrations].insert(filename: filename)
      else
        puts "Warning: No migration file found for version #{row[:version]}"
      end
    end

    # Drop old table
    db.drop_table(:schema_migrations_old)

    puts 'Schema_migrations table migration complete.'
  end
end
