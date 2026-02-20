# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

class AppConfig
  # Module containing specific configuration accessor methods
  # Some legacy overrides are still present for backward compatibility
  # see comments marked # legacy override, remove in future
  module Accessors
    # Default configuration values
    DEFAULT_CLEANUP_SCHEDULE = '10m'
    DEFAULT_LOCALE = 'en'
    DEFAULT_MAX_MSG_LENGTH = 20_000
    DEFAULT_MIN_CALC_LENGTH = 256
    DEFAULT_CALC_LENGTH_THRESHOLD = 128
    DEFAULT_RATE_LIMIT = 65
    DEFAULT_RATE_LIMIT_PERIOD = 60 # in seconds
    DEFAULT_BASE_URL = '/'

    # Helper methods for deprecation warnings
    def self.warn_deprecated_env(old_var, new_var)
      warn "[DEPRECATION] ENV['#{old_var}'] is deprecated; use ENV['#{new_var}'] instead"
    end

    def self.warn_deprecated_config(old_key, new_key)
      warn "[DEPRECATION] Config key '#{old_key}' is deprecated; use '#{new_key}' instead"
    end

    def custom
      load! unless @config
      @config.custom || {}
    end

    def permitted_origins
      return ENV['AHA_SECRET_PERMITTED_ORIGINS'] if ENV.key?('AHA_SECRET_PERMITTED_ORIGINS')

      load! unless @config
      # Config file setting
      origin = @config.permitted_origins
      return origin unless origin.nil? || origin.to_s.empty?

      # legacy override, remove in future
      ENV.fetch('URL', nil)
    end

    def cleanup_schedule
      load! unless @config
      @config.cleanup_schedule || DEFAULT_CLEANUP_SCHEDULE
    end

    def default_locale
      load! unless @config
      @config.default_locale || DEFAULT_LOCALE
    end

    def max_msg_length
      load! unless @config
      coerce_integer(@config.max_msg_length, DEFAULT_MAX_MSG_LENGTH)
    end

    def random_secret_symbols
      load! unless @config
      ret = @config.random_secret_symbols
      ret = true if @config.random_secret_symbols.nil?
      ret
    end

    def random_secret_numbers
      load! unless @config
      ret = @config.random_secret_numbers
      ret = true if @config.random_secret_numbers.nil?
      ret
    end

    def random_secret_capitals
      load! unless @config
      ret = @config.random_secret_capitals
      ret = true if @config.random_secret_capitals.nil?
      ret
    end

    def random_secret_lowers
      load! unless @config
      ret = @config.random_secret_lowers
      ret = true if @config.random_secret_lowers.nil?
      ret
    end

    def random_secret_default_length
      load! unless @config
      coerce_integer(@config.random_secret_default_length, 16)
    end

    def random_secret_max_length
      load! unless @config
      coerce_integer(@config.random_secret_max_length, 1024)
    end

    def random_secret_min_length
      load! unless @config
      coerce_integer(@config.random_secret_min_length, 16)
    end

    def calc_max_length
      load! unless @config
      max = max_msg_length
      if max <= DEFAULT_CALC_LENGTH_THRESHOLD
        DEFAULT_MIN_CALC_LENGTH
      else
        max * 2
      end
    end

    def rate_limit
      load! unless @config
      # TODO: Consider validating non-positive or non-numeric values and falling back to defaults.
      coerce_integer(@config.rate_limit, DEFAULT_RATE_LIMIT)
    end

    def rate_limit_period
      load! unless @config
      # TODO: Consider validating non-positive or non-numeric values and falling back to defaults.
      coerce_integer(@config.rate_limit_period, DEFAULT_RATE_LIMIT_PERIOD)
    end

    def session_secret
      return ENV['AHA_SECRET_SESSION_SECRET'] if ENV.key?('AHA_SECRET_SESSION_SECRET')

      # legacy override, remove in future
      if ENV.key?('SESSION_SECRET')
        Accessors.warn_deprecated_env('SESSION_SECRET', 'AHA_SECRET_SESSION_SECRET')
        return ENV['SESSION_SECRET']
      end

      load! unless @config
      @config.session_secret || SecureRandom.hex(64)
    end

    def memcache_url
      load! unless @config
      @config.memcache_url || ENV.fetch('MEMCACHE', nil)
    end

    def base_url
      load! unless @config
      @config.base_url || DEFAULT_BASE_URL
    end

    def app_locale
      return ENV['AHA_SECRET_APP_LOCALE'] if ENV.key?('AHA_SECRET_APP_LOCALE')

      # legacy override, remove in future
      if ENV.key?('APP_LOCALE')
        Accessors.warn_deprecated_env('APP_LOCALE', 'AHA_SECRET_APP_LOCALE')
        return ENV['APP_LOCALE']
      end

      nil
    end

    private

    def coerce_integer(value, default)
      return default if value.nil?
      return value if value.is_a?(Integer)

      Integer(value)
    rescue ArgumentError, TypeError
      warn "[CONFIG WARNING] Expected integer but got '#{value.inspect}'. Falling back to #{default}."
      default
    end
  end
end
# rubocop:enable Metrics/ModuleLength
