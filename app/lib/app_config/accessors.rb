# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

class AppConfig
  # Module containing specific configuration accessor methods
  module Accessors
    # Default configuration values
    DEFAULT_CLEANUP_SCHEDULE      = '10m'
    DEFAULT_LOCALE                = 'en'
    DEFAULT_MAX_MSG_LENGTH        = 20_000
    DEFAULT_MIN_CALC_LENGTH       = 256
    DEFAULT_CALC_LENGTH_THRESHOLD = 128
    DEFAULT_RATE_LIMIT            = 65
    DEFAULT_RATE_LIMIT_PERIOD     = 60 # in seconds
    DEFAULT_BASE_URL              = '/'

    # Helper methods for deprecation warnings
    def self.warn_deprecated_env(old_var, new_var)
      warn "[DEPRECATION] ENV['#{old_var}'] is no longer supported and will be ignored; use ENV['#{new_var}'] instead"
    end

    def self.warn_deprecated_config(old_key, new_key)
      warn "[DEPRECATION] Config key '#{old_key}' is no longer supported and will be ignored; use '#{new_key}' instead"
    end

    def custom
      ensure_loaded
      @config.custom || {}
    end

    def permitted_origins
      value =
        if ENV.key?('AHA_SECRET_PERMITTED_ORIGINS')
          ENV['AHA_SECRET_PERMITTED_ORIGINS']
        else
          ensure_loaded
          @config.permitted_origins
        end

      return nil if value.nil?

      if value.respond_to?(:strip)
        stripped = value.strip
        return nil if stripped.empty?
        return stripped
      end

      value
    end

    def cleanup_schedule
      ensure_loaded
      @config.cleanup_schedule || DEFAULT_CLEANUP_SCHEDULE
    end

    def default_locale
      ensure_loaded
      @config.default_locale || DEFAULT_LOCALE
    end

    def max_msg_length
      ensure_loaded
      coerce_integer(@config.max_msg_length, DEFAULT_MAX_MSG_LENGTH)
    end

    def random_secret_symbols
      random_secret_flag(:random_secret_symbols)
    end

    def random_secret_numbers
      random_secret_flag(:random_secret_numbers)
    end

    def random_secret_capitals
      random_secret_flag(:random_secret_capitals)
    end

    def random_secret_lowers
      random_secret_flag(:random_secret_lowers)
    end

    def random_secret_default_length
      ensure_loaded
      coerce_integer(@config.random_secret_default_length, 16)
    end

    def random_secret_max_length
      ensure_loaded
      coerce_integer(@config.random_secret_max_length, 1024)
    end

    def random_secret_min_length
      ensure_loaded
      coerce_integer(@config.random_secret_min_length, 16)
    end

    def calc_max_length
      ensure_loaded
      max = max_msg_length
      max <= DEFAULT_CALC_LENGTH_THRESHOLD ? DEFAULT_MIN_CALC_LENGTH : max * 2
    end

    def rate_limit
      ensure_loaded
      coerce_integer(@config.rate_limit, DEFAULT_RATE_LIMIT)
    end

    def rate_limit_period
      ensure_loaded
      coerce_integer(@config.rate_limit_period, DEFAULT_RATE_LIMIT_PERIOD)
    end

    def session_secret
      return ENV['AHA_SECRET_SESSION_SECRET'] if ENV.key?('AHA_SECRET_SESSION_SECRET')

      ensure_loaded
      @config.session_secret || SecureRandom.hex(64)
    end

    def memcache_url
      ensure_loaded
      @config.memcache_url
    end

    def base_url
      ensure_loaded
      @config.base_url || DEFAULT_BASE_URL
    end

    def app_locale
      return ENV['AHA_SECRET_APP_LOCALE'] if ENV.key?('AHA_SECRET_APP_LOCALE')

      nil
    end

    private

    def ensure_loaded
      load! unless @config
    end

    def random_secret_flag(field)
      ensure_loaded
      value = @config.public_send(field)
      return true if value.nil?

      value
    end

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
