# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'
require_relative 'lib/aha_secret/version'

# Migration check is done in config/environment.rb via Sequel::Migrator.check_current

# Log application version on startup
logger = Logger.new($stdout)
logger.info("AHA-Secret version: #{AhaSecret::VERSION}")

if AppConfig.memcache_url
  use Rack::Attack
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(AppConfig.memcache_url, options)

  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  Rack::Attack.throttle('requests by ip', limit: AppConfig.rate_limit, period: AppConfig.rate_limit_period, &:ip)
end

use Rack::MethodOverride
use Rack::Session::Cookie,
    domain: ->(env) { Rack::Request.new(env).host },
    path: '/',
    expire_after: 3600 * 24,
    secret: AppConfig.session_secret
use Rack::Protection,
    use: %i[content_security_policy authenticity_token],
    permitted_origins: AppConfig.permitted_origins

# Test-specific rate limiting configuration (for rate_limit_feature_spec.rb)
if ENV.include?('MEMCACHE') && ENV['RACK_ENV'] == 'test'
  use Rack::Attack
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(ENV.fetch('MEMCACHE'), options)

  # Don't allow localhost in test environment
  Rack::Attack.safelist('allow from localhost') do |_req|
    false
  end

  Rack::Attack.throttle('requests by ip', limit: (ENV['RACK_ENV'] == 'test' ? 3 : AppConfig.rate_limit),
                                          period: AppConfig.rate_limit_period) do |req|
    # In test, use REMOTE_ADDR if present, fallback to req.ip
    req.env['REMOTE_ADDR'] || req.ip
  end
end

run ApplicationController
