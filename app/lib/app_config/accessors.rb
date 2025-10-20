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
      @config.random_secret_default_length || 16
    end

    def random_secret_max_length
      load! unless @config
      @config.random_secret_max_length || 1024
    end

    def random_secret_min_length
      load! unless @config
      @config.random_secret_min_length || 16
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
      load! unless @config
      @config.memcache_url || ENV.fetch('MEMCACHE', nil)
    end

    def base_url
      load! unless @config
      @config.base_url || '/'
    end
  end
end
