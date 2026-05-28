# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'database initializer' do
  describe '#sequel_config_from_yml' do
    it 'builds a sqlite config for local environments' do
      config = sequel_config_from_yml(
        {
          'development' => {
            'adapter' => 'sqlite3',
            'database' => 'db/database/development.sqlite3'
          }
        },
        'development'
      )

      expect(config).to eq(adapter: 'sqlite', database: 'db/database/development.sqlite3')
    end
  end

  describe '#resolve_database_config' do
    it 'falls back to sqlite when database.yml is missing' do
      expect(resolve_database_config('/tmp/does-not-exist.yml', 'development')).to eq(
        adapter: 'sqlite',
        database: 'db/database/development.sqlite3'
      )
    end
  end
end