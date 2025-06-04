# frozen_string_literal: true

require 'yaml'
require_relative 'app_config/loader'
require_relative 'app_config/accessors'

# AppConfig is a configuration management class that handles application-wide settings.
#
# This class provides a mechanism to load and access configuration settings from a YAML file.
# It supports environment-specific configurations and falls back to default values when needed.
# The configuration is loaded lazily when first accessed and stored as an OpenStruct instance.
#
# @example Loading and accessing configuration
#   AppConfig.load!('development') # Explicitly load development configuration
#   AppConfig.some_setting        # Access a configuration value
#
# @note Configuration is automatically loaded on first method access if not loaded explicitly
#
# The configuration file is expected to be located at 'config/config.yml' relative to the
# application root directory. The YAML file should contain environment-specific sections
# and may include a 'default' section for fallback values.
#
# Configuration values can be accessed as methods on the AppConfig class, which are
# dynamically delegated to the underlying Struct instance.
class AppConfig
  extend Loader
  extend Accessors
  @config = nil
  # Core config keys (permitted_origins is optional)
  REQUIRED_KEYS = %w[rate_limit rate_limit_period cleanup_schedule base_url default_locale max_msg_length custom
                     memcache_url session_secret].freeze
  # Additional config keys that are optional and not validated
  OPTIONAL_KEYS = %w[permitted_origins].freeze

  # ConfigStruct includes REQUIRED_KEYS + OPTIONAL_KEYS
  ConfigStruct = Struct.new(*(REQUIRED_KEYS + OPTIONAL_KEYS).map(&:to_sym)) do
    def self.from_hash(hash)
      # Ensure all keys are symbols and fill missing keys with nil
      fields = REQUIRED_KEYS + OPTIONAL_KEYS
      args = fields.map { |k| hash[k.to_s] }
      new(*args)
    end
  end

  def self.load!(env = ENV['RACK_ENV'] || 'development')
    raw = load_config_file
    config_hash = build_config_hash(raw, env)
    validate_config!(config_hash)
    @config = ConfigStruct.from_hash(config_hash)
    @config.freeze
  end

  def self.reload!(env = ENV['RACK_ENV'] || 'development')
    @config = nil
    load!(env)
  end

  def self.method_missing(method_name, *, &)
    load! unless @config
    if @config.respond_to?(method_name)
      @config.public_send(method_name, *, &)
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    load! unless @config
    @config.respond_to?(method_name) || super
  end
end
