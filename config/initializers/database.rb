# frozen_string_literal: true

require 'sequel'
require 'yaml'
require 'logger'

SQLITE_FALLBACK_PATH = 'db/database/development.sqlite3'

def connect_with_database_url
  Sequel.connect(ENV.fetch('DATABASE_URL', nil))
end

def db_config_file_path
  File.expand_path('../../config/database.yml', __dir__)
end

def normalize_adapter(adapter)
  return 'postgres' if %w[postgres postgresql].include?(adapter)
  return 'sqlite' if adapter == 'sqlite3'

  adapter
end

def database_config_value(key, value)
  return if value.nil? || value == ''

  normalized_key = case key
                   when 'username' then :user
                   when 'pool' then :max_connections
                   else key.to_sym
                   end

  [normalized_key, value]
end

def merge_database_settings(env_config, config)
  %w[host port user username password encoding max_connections pool timeout].each do |key|
    normalized_entry = database_config_value(key, env_config[key])
    next unless normalized_entry

    normalized_key, value = normalized_entry
    config[normalized_key] = value
  end
end

def coerce_database_settings(config)
  config[:port] = config[:port].to_i if config[:port]
  config[:max_connections] = config[:max_connections].to_i if config[:max_connections]
  config[:pool_timeout] = config.delete(:timeout).to_i if config[:timeout]
  config
end

def sequel_config_from_yml(db_config, env)
  env_config = db_config.fetch(env, {})
  config = {
    adapter: normalize_adapter(env_config.fetch('adapter', 'sqlite3')),
    database: env_config.fetch('database', SQLITE_FALLBACK_PATH)
  }

  merge_database_settings(env_config, config)
  coerce_database_settings(config)
end

def connect_with_database_yml
  env = ENV['RACK_ENV'] || 'development'
  file = db_config_file_path
  db_config = resolve_database_config(file, env)
  Sequel.connect(db_config)
end

def resolve_database_config(file, env)
  if File.exist?(file)
    require 'erb'
    db_config = YAML.safe_load(ERB.new(File.read(file)).result, aliases: true)
    sequel_config_from_yml(db_config, env)
  else
    warn_missing_database_yml(file, env)
    { adapter: 'sqlite', database: SQLITE_FALLBACK_PATH }
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
