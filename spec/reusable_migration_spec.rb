# frozen_string_literal: true

require_relative 'spec_helper'
require 'tempfile'

RSpec.describe 'Reusable bins migration' do
  let(:database_file) { Tempfile.new(['reusable_migration', '.sqlite3']) }
  let(:database) { Sequel.connect("sqlite://#{database_file.path}") }
  let(:migrations_path) { File.expand_path('../db/migrate', __dir__) }
  let(:previous_migration) { 20_240_914_195_836 }
  let(:reusable_migration) { 20_260_727_090_000 }

  after do
    database.disconnect
    database_file.close!
  end

  it 'adds reusable as false for existing bins and can migrate back down' do
    Sequel::TimestampMigrator.run(database, migrations_path, target: previous_migration)
    database[:bins].insert(
      id: 'existing-bin',
      payload: 'ciphertext',
      created_at: Time.now.utc,
      updated_at: Time.now.utc,
      expire_date: Time.now.utc + 60
    )

    Sequel::TimestampMigrator.run(database, migrations_path, target: reusable_migration)

    expect(database.schema(:bins).to_h.fetch(:reusable).fetch(:allow_null)).to be false
    expect(database[:bins].first.fetch(:reusable)).to be false

    Sequel::TimestampMigrator.run(database, migrations_path, target: previous_migration)

    expect(database.schema(:bins).to_h).not_to have_key(:reusable)
    expect(database[:bins].first.fetch(:id)).to eq('existing-bin')
  end
end
