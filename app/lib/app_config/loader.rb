# frozen_string_literal: true

require 'yaml'

class AppConfig
  # Module responsible for loading and building configuration from YAML files and environment variables
  module Loader
    def load_config_file
      config_path = File.expand_path('../../../config/config.yml', __dir__)
      raise "Config file not found: #{config_path}" unless File.exist?(config_path)

      YAML.load_file(config_path, aliases: true)
    end

    def build_config_hash(raw, env)
      config_hash = load_base_config(raw, env)
      apply_deprecated_config_keys(config_hash)
      apply_deprecated_env_vars(config_hash)
      apply_env_overrides(config_hash)
      config_hash
    end

    def load_base_config(raw, env)
      ((raw[env] || raw['default']) || {}).transform_keys(&:to_s)
    end

    def apply_deprecated_config_keys(config_hash)
      deprecated_config_mappings.each do |old_key, new_key|
        next unless config_hash.key?(old_key)

        Accessors.warn_deprecated_config(old_key, new_key)
        # Only set the new key if it's not explicitly set (new key takes precedence)
        # But we need to distinguish between inherited values and explicitly set values
        # For now, we'll use a simple approach: if both exist, prefer the new key
        config_hash[new_key] = config_hash[old_key] unless config_hash.key?(new_key)
        config_hash.delete(old_key)
      end
    end

    def apply_deprecated_env_vars(config_hash)
      deprecated_mappings.each do |old_var, config_keys|
        next unless ENV.key?(old_var)

        new_var = "AHA_SECRET_#{config_keys.first.upcase}"
        Accessors.warn_deprecated_env(old_var, new_var)
        config_keys.each { |k| config_hash[k] = ENV.fetch(old_var, nil) }
      end
    end

    def apply_env_overrides(config_hash)
      # Apply environment variable overrides for both required and optional keys
      (REQUIRED_KEYS + OPTIONAL_KEYS).each do |key|
        env_key = "AHA_SECRET_#{key.upcase}"
        next unless ENV.key?(env_key)

        # Convert boolean-like strings to actual booleans
        value = ENV.fetch(env_key, nil)
        value = case value.to_s.downcase
                when 'true', '1', 'yes', 'on'
                  true
                when 'false', '0', 'no', 'off', ''
                  false
                else
                  value
                end

        config_hash[key] = value
      end
    end

    def deprecated_mappings
      {
        'URL' => %w[permitted_origins],
        'MEMCACHE' => %w[memcache_url],
        'SESSION_SECRET' => %w[session_secret],
        'PERMITTED_ORIGINS' => %w[permitted_origins]
      }
    end

    def deprecated_config_mappings
      {
        'url' => 'base_url'
      }
    end

    def validate_config!(config_hash)
      missing = REQUIRED_KEYS - config_hash.keys
      raise "Missing required config keys: #{missing.join(', ')}" unless missing.empty?
    end
  end
end
