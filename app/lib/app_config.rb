# frozen_string_literal: true

require 'yaml'
require 'ostruct'

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
# dynamically delegated to the underlying OpenStruct instance.
class AppConfig
  @config = nil
  REQUIRED_KEYS = %w[rate_limit rate_limit_period cleanup_schedule url default_locale max_msg_length custom].freeze

  ConfigStruct = Struct.new(*REQUIRED_KEYS.map(&:to_sym)) do
    def self.from_hash(hash)
      # Ensure all keys are symbols and fill missing keys with nil
      args = REQUIRED_KEYS.map { |k| hash[k.to_s] }
      new(*args)
    end
  end

  def self.load!(env = ENV['RACK_ENV'] || 'development')
    config_path = File.expand_path('../../config/config.yml', __dir__)
    raise "Config file not found: #{config_path}" unless File.exist?(config_path)

    raw = YAML.load_file(config_path, aliases: true)
    config_hash = build_config_hash(raw, env)
    validate_config!(config_hash)
    @config = ConfigStruct.from_hash(config_hash)
    @config.freeze
  end

  def self.build_config_hash(raw, env)
    config_hash = (raw[env] || raw['default']) || {}
    config_hash = config_hash.transform_keys(&:to_s)
    REQUIRED_KEYS.each do |key|
      env_key = "APP_CONFIG_#{key.upcase}"
      config_hash[key] = ENV[env_key] if ENV[env_key]
    end
    config_hash
  end

  def self.reload!(env = ENV['RACK_ENV'] || 'development')
    @config = nil
    load!(env)
  end

  def self.validate_config!(config_hash)
    missing = REQUIRED_KEYS - config_hash.keys
    raise "Missing required config keys: #{missing.join(', ')}" unless missing.empty?
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

  def self.max_msg_length
    load! unless @config
    @config.max_msg_length || 10_000
  end

  def self.calc_max_length
    load! unless @config
    max = @config.max_msg_length || 10_000
    if max < 128
      256
    else
      max * 2
    end
  end

  def self.rate_limit
    @config.rate_limit || 100
  end

  def self.rate_limit_period
    @config.rate_limit_period || 1.minute
  end

  # Uncomment and implement these methods if needed
  # def self.cleanup_interval
  #   @config.cleanup_interval || '1h'
  # end

  # def self.cleanup_schedule
  #   @config.cleanup_schedule || '1h'
  # end

  # def self.default_locale
  #   @config.default_locale || 'en'
  # end

  # def self.session_secret
  #   @config.session_secret || SecureRandom.hex(64)
  # end

  # def self.memcache_url
  #   @config.memcache_url || ENV['MEMCACHE']
  # end
end
