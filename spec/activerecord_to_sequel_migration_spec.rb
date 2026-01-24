# frozen_string_literal: true
# TODO: we can remove this, if the feature branch is merged

require_relative 'spec_helper'
require 'tempfile'
require 'sequel'

RSpec.describe 'ActiveRecord to Sequel migration' do
  let(:test_db_path) { File.join(Dir.tmpdir, "test_migration_#{Time.now.to_i}.sqlite3") }
  let(:test_db) { Sequel.connect("sqlite://#{test_db_path}") }

  after do
    test_db.disconnect
    File.delete(test_db_path) if File.exist?(test_db_path)
  end

  it 'converts ActiveRecord schema_migrations to Sequel format' do
    # Setup: Create an ActiveRecord-style schema_migrations table
    test_db.create_table(:schema_migrations) do
      String :version, primary_key: true, null: false
    end

    # Insert some test versions
    test_db[:schema_migrations].insert(version: '20240322074525')
    test_db[:schema_migrations].insert(version: '20240324133511')
    test_db[:schema_migrations].insert(version: '20240914195836')

    # Verify initial state
    expect(test_db.schema(:schema_migrations).map(&:first)).to eq([:version])
    expect(test_db[:schema_migrations].count).to eq(3)

    # Run the conversion
    convert_activerecord_schema_migrations_to_sequel!(test_db, verbose: false)

    # Verify new structure
    columns = test_db.schema(:schema_migrations).map(&:first)
    expect(columns).to eq([:filename])

    # Verify data was migrated correctly
    filenames = test_db[:schema_migrations].select_order_map(:filename)
    expect(filenames).to contain_exactly(
      '20240322074525_create_bins.rb',
      '20240324133511_add_random_id.rb',
      '20240914195836_add_has_password_to_bins.rb'
    )
  end

  it 'skips conversion if already in Sequel format' do
    # Setup: Create a Sequel-style schema_migrations table
    test_db.create_table(:schema_migrations) do
      String :filename, primary_key: true, null: false
    end

    test_db[:schema_migrations].insert(filename: '20240322074525_create_bins.rb')

    # Run the conversion
    expect {
      convert_activerecord_schema_migrations_to_sequel!(test_db, verbose: false)
    }.not_to raise_error

    # Verify structure unchanged
    columns = test_db.schema(:schema_migrations).map(&:first)
    expect(columns).to eq([:filename])
    expect(test_db[:schema_migrations].count).to eq(1)
  end

  it 'skips conversion if table does not exist' do
    # No schema_migrations table exists
    expect(test_db.table_exists?(:schema_migrations)).to be false

    # Should not raise error
    expect {
      convert_activerecord_schema_migrations_to_sequel!(test_db, verbose: false)
    }.not_to raise_error
  end

  it 'handles versions without matching migration files gracefully' do
    # Setup: Create an ActiveRecord-style schema_migrations table
    test_db.create_table(:schema_migrations) do
      String :version, primary_key: true, null: false
    end

    # Insert a version that doesn't have a corresponding file
    test_db[:schema_migrations].insert(version: '20991231235959')

    # Should not raise error, just skip the non-existent file
    expect {
      convert_activerecord_schema_migrations_to_sequel!(test_db, verbose: false)
    }.not_to raise_error

    # Verify the table structure was converted even though no files matched
    columns = test_db.schema(:schema_migrations).map(&:first)
    expect(columns).to eq([:filename])
    expect(test_db[:schema_migrations].count).to eq(0) # No matching files
  end

  it 'preserves bin data when migrating from ActiveRecord to Sequel' do
    # Setup: Create ActiveRecord-style schema_migrations and bins tables
    test_db.create_table(:schema_migrations) do
      String :version, primary_key: true, null: false
    end

    # Create bins table (matching the schema from main branch)
    test_db.create_table(:bins, id: false) do
      String :id, primary_key: true, null: false
      String :payload, text: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      DateTime :expire_date
      TrueClass :has_password, default: false
    end

    # Insert migration versions (simulating main branch state)
    test_db[:schema_migrations].insert(version: '20240322074525')
    test_db[:schema_migrations].insert(version: '20240324133511')
    test_db[:schema_migrations].insert(version: '20240325152739')
    test_db[:schema_migrations].insert(version: '20240914195836')

    # Create a test bin/secret (simulating creating a secret in main branch)
    secret_id = 'test_secret_123'
    secret_payload = 'This is my super secret message!'
    created_time = Time.now
    expire_time = created_time + (7 * 24 * 60 * 60) # 7 days from now

    test_db[:bins].insert(
      id: secret_id,
      payload: secret_payload,
      created_at: created_time,
      updated_at: created_time,
      expire_date: expire_time,
      has_password: false
    )

    # Verify the bin was created
    expect(test_db[:bins].count).to eq(1)
    original_bin = test_db[:bins].first
    expect(original_bin[:id]).to eq(secret_id)
    expect(original_bin[:payload]).to eq(secret_payload)

    # Run the migration conversion (simulating switching to sequel-integration branch)
    convert_activerecord_schema_migrations_to_sequel!(test_db, verbose: false)

    # Verify schema_migrations was converted
    expect(test_db.schema(:schema_migrations).map(&:first)).to eq([:filename])

    # Most importantly: verify the bin data is still intact and readable
    revealed_bin = test_db[:bins].where(id: secret_id).first
    expect(revealed_bin).not_to be_nil
    expect(revealed_bin[:id]).to eq(secret_id)
    expect(revealed_bin[:payload]).to eq(secret_payload)
    expect(revealed_bin[:has_password]).to eq(false)
    expect(revealed_bin[:expire_date]).to be_within(1).of(expire_time)

    # Verify we can delete the bin (simulating reveal)
    deleted_count = test_db[:bins].where(id: secret_id).delete
    expect(deleted_count).to eq(1)
    expect(test_db[:bins].where(id: secret_id).first).to be_nil
  end
end
