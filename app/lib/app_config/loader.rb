# frozen_string_literal: true

require 'yaml'

class AppConfig
  # Module responsible for loading and building configuration from YAML files and environment variables
  module Loader
    BOOLEAN_TRUE_VALUES  = %w[true 1 yes on].freeze
    BOOLEAN_FALSE_VALUES = %w[false 0 no off].freeze

    LEGACY_ENV_MAPPINGS = {
      'URL' => 'AHA_SECRET_PERMITTED_ORIGINS',
      'MEMCACHE' => 'AHA_SECRET_MEMCACHE_URL',
      'SESSION_SECRET' => 'AHA_SECRET_SESSION_SECRET',
      'PERMITTED_ORIGINS' => 'AHA_SECRET_PERMITTED_ORIGINS',
      'APP_LOCALE' => 'AHA_SECRET_APP_LOCALE'
    }.freeze

    LEGACY_CONFIG_MAPPINGS = {
      'url' => 'base_url'
    }.freeze

    def load_config_file
      config_path = File.expand_path('../../../config/config.yml', __dir__)
      raise "Config file not found: #{config_path}" unless File.exist?(config_path)

      YAML.load_file(config_path, aliases: true)
    end

    def build_config_hash(raw, env)
      config_hash = load_base_config(raw, env)
      warn_ignored_legacy_config_keys(config_hash)
      warn_ignored_legacy_env_vars
      apply_env_overrides(config_hash)
      config_hash
    end

    def load_base_config(raw, env)
      (raw[env] || raw['default'] || {}).transform_keys(&:to_s)
    end

    def warn_ignored_legacy_config_keys(config_hash)
      LEGACY_CONFIG_MAPPINGS.each do |old_key, new_key|
        next unless config_hash.key?(old_key)

        Accessors.warn_deprecated_config(old_key, new_key)
      end
    end

    def warn_ignored_legacy_env_vars
      LEGACY_ENV_MAPPINGS.each do |old_var, new_var|
        next unless ENV.key?(old_var)

        Accessors.warn_deprecated_env(old_var, new_var)
      end
    end

    def apply_env_overrides(config_hash)
      config_override_keys.each do |key|
        apply_env_override(config_hash, key)
      end
    end

    private

    def config_override_keys
      REQUIRED_KEYS + OPTIONAL_KEYS
    end

    def apply_env_override(config_hash, key)
      env_key = env_override_key(key)
      return unless ENV.key?(env_key)

      config_hash[key] = normalize_env_override(ENV.fetch(env_key))
    end

    def env_override_key(key)
      "AHA_SECRET_#{key.upcase}"
    end

    def normalize_env_override(value)
      normalized = value.to_s.downcase
      return true  if BOOLEAN_TRUE_VALUES.include?(normalized)
      return false if BOOLEAN_FALSE_VALUES.include?(normalized)

      value
    end

    def validate_config!(config_hash)
      missing = REQUIRED_KEYS - config_hash.keys
      raise "Missing required config keys: #{missing.join(', ')}" if missing.any?
    end
  end
end
