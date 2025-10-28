# frozen_string_literal: true

class AppConfig
  # Module containing specific configuration accessor methods
  # Some legacy overrides are still present for backward compatibility
  # see line \# legacy override, remove in future
  module Accessors
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
      @config.cleanup_schedule || '5m'
    end

    def default_locale
      load! unless @config
      @config.default_locale || 'en'
    end

    def max_msg_length
      load! unless @config
      @config.max_msg_length || 10_000
    end

    def calc_max_length
      load! unless @config
      max = @config.max_msg_length || 10_000
      if max < 128
        256
      else
        max * 2
      end
    end

    def rate_limit
      load! unless @config
      @config.rate_limit || 15
    end

    def rate_limit_period
      load! unless @config
      @config.rate_limit_period || 1.minute
    end

    def session_secret
      return ENV['AHA_SECRET_SESSION_SECRET'] if ENV.key?('AHA_SECRET_SESSION_SECRET')

      # legacy override, remove in future
      return ENV['SESSION_SECRET'] if ENV.key?('SESSION_SECRET')

      load! unless @config
      @config.session_secret || SecureRandom.hex(64)
    end

    def memcache_url
      load! unless @config
      @config.memcache_url || ENV.fetch('MEMCACHE', nil)
    end

    def base_url
      load! unless @config
      @config.base_url || '/'
    end

    def app_locale
      return ENV['AHA_SECRET_APP_LOCALE'] if ENV.key?('AHA_SECRET_APP_LOCALE')

      # legacy override, remove in future
      if ENV.key?('APP_LOCALE')
        warn "[DEPRECATION] ENV['APP_LOCALE'] is deprecated; use ENV['AHA_SECRET_APP_LOCALE'] instead"
        return ENV['APP_LOCALE']
      end

      nil
    end
  end
end
