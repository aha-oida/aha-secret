# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'

ActiveRecord::Migration.check_all_pending!

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

if ENV.include? 'MEMCACHE'
  # Minimal working example for IP throttling with Memcached
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(ENV.fetch('MEMCACHE'), options)

  # Allow localhost, except in test environment
  Rack::Attack.safelist('allow from localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip) && ENV['RACK_ENV'] != 'test'
  end

  Rack::Attack.throttle('requests by ip', limit: (ENV['RACK_ENV'] == 'test' ? 3 : 64), period: 60) do |req|
    # In test, use REMOTE_ADDR if present, fallback to req.ip
    if ENV['RACK_ENV'] == 'test' && req.env['REMOTE_ADDR']
      req.env['REMOTE_ADDR']
    else
      req.ip
    end
  end
end

run ApplicationController
