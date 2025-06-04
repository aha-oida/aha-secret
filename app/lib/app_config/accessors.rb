# frozen_string_literal: true

class AppConfig
  # Module containing specific configuration accessor methods
  module Accessors
    def custom
      load! unless @config
      @config.custom || {}
    end

    def permitted_origins
      # ENV override takes priority
      return ENV['AHA_SECRET_PERMITTED_ORIGINS'] if ENV.key?('AHA_SECRET_PERMITTED_ORIGINS')

      load! unless @config
      # Config file setting
      origin = @config.permitted_origins
      return origin unless origin.nil? || origin.to_s.empty?

      # Legacy fallback to URL environment variable
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
      @config.rate_limit || 100
    end

    def rate_limit_period
      load! unless @config
      @config.rate_limit_period || 1.minute
    end

    def session_secret
      # New prefix-based ENV override
      return ENV['AHA_SECRET_SESSION_SECRET'] if ENV.key?('AHA_SECRET_SESSION_SECRET')
      # Legacy env var for backward compatibility
      return ENV['SESSION_SECRET'] if ENV.key?('SESSION_SECRET')

      load! unless @config
      @config.session_secret || SecureRandom.hex(64)
    end

    def memcache_url
      return ENV['AHA_SECRET_MEMCACHE'] if ENV.key?('AHA_SECRET_MEMCACHE')

      load! unless @config
      @config.memcache_url || ENV.fetch('MEMCACHE', nil)
    end

    def base_url
      return ENV['AHA_SECRET_BASE_URL'] if ENV.key?('AHA_SECRET_BASE_URL')

      load! unless @config
      return @config.base_url if @config.base_url

      return @config.url || '/'
    end
  end
end
