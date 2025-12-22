# frozen_string_literal: true

require 'sequel'
require 'yaml'
require 'logger'

def connect_with_database_url
  Sequel.connect(ENV.fetch('DATABASE_URL', nil))
end

def db_config_file_path
  File.expand_path('../../config/database.yml', __dir__)
end

def database_path_from_yml(db_config, env)
  db_config.dig(env, 'database') || 'db/database/development.sqlite3'
end

def connect_with_database_yml
  env = ENV['RACK_ENV'] || 'development'
  file = db_config_file_path
  database_path = resolve_database_path(file, env)
  Sequel.connect("sqlite://#{database_path}")
end

def resolve_database_path(file, env)
  if File.exist?(file)
    require 'erb'
    db_config = YAML.safe_load(ERB.new(File.read(file)).result, aliases: true)
    database_path_from_yml(db_config, env)
  else
    warn_missing_database_yml(file, env)
    'db/database/development.sqlite3'
  end
end

def warn_missing_database_yml(file, env)
  warn "WARNING: Missing database.yml at #{file}, using default SQLite path." if %w[development test].include?(env)
end

def setup_database_connection!
  db = ENV['DATABASE_URL'] ? connect_with_database_url : connect_with_database_yml
  db.loggers << Logger.new($stdout) if ENV['RACK_ENV'] == 'development'
  Sequel::Model.db = db
  db
end

DB = setup_database_connection!
