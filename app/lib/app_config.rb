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

  def self.load!(env = ENV['RACK_ENV'] || 'development')
    config_path = File.expand_path('../../config/config.yml', __dir__)
    raw = YAML.load_file(config_path, aliases: true)
    @config = OpenStruct.new(raw[env] || raw['default'])
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

  def self.calc_max_length
    unless @config&.max_msg_length
      @config ||= OpenStruct.new
      @config.max_msg_length = 10_000
    end

    if @config.max_msg_length < 128
      256
    else
      @config.max_msg_length * 2
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
