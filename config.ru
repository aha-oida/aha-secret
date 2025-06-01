# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'

ActiveRecord::Migration.check_all_pending!

if ENV.include? 'MEMCACHE'
  # Move Rack::Attack to the very top of the middleware stack
  use Rack::Attack
end

use Rack::MethodOverride
use Rack::Session::Cookie,
    domain: ->(env) { Rack::Request.new(env).host },
    path: '/',
    expire_after: 3600 * 24,
    secret: ENV.fetch('SESSION_SECRET', SecureRandom.hex(64))
use Rack::Protection,
    use: %i[content_security_policy authenticity_token],
    permitted_origins: ENV.fetch('URL', nil)

if ENV.include? 'MEMCACHE'
  # Minimal working example for IP throttling with Memcached
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(ENV.fetch('MEMCACHE'), options)

  # Allow localhost, except in test environment
  Rack::Attack.safelist('allow from localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip) && ENV['RACK_ENV'] != 'test'
  end

  # Debug: log each request's IP and throttle count
  Rack::Attack.throttled_response = lambda do |env|
    req = Rack::Request.new(env)
    key = "rack::attack:#{req.ip}:requests by ip"
    count = begin
      Rack::Attack.cache.store.get(key)
    rescue StandardError
      'N/A'
    end
    puts "[DEBUG] Throttled response for IP: #{req.ip}, count: #{count}"
    [429, {}, ['Rate limit exceeded']]
  end

  Rack::Attack.throttle('requests by ip', limit: (ENV['RACK_ENV'] == 'test' ? 3 : 64), period: 60) do |req|
    key = "rack::attack:#{req.ip}:requests by ip"
    count = begin
      Rack::Attack.cache.store.get(key)
    rescue StandardError
      'N/A'
    end
    puts "[DEBUG] Throttle check for IP: #{req.ip}, count: #{count}"
    req.ip
  end
end

run ApplicationController
