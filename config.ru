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
    (req.ip == '127.0.0.1' || req.ip == '::1') && ENV['RACK_ENV'] != 'test'
  end

  # Use a lower limit in test environment for reliable feature specs
  if ENV['RACK_ENV'] == 'test'
    Rack::Attack.throttle('requests by ip', limit: 3, period: 60) { |req| req.ip }
  else
    Rack::Attack.throttle('requests by ip', limit: 64, period: 60) { |req| req.ip }
  end
end

run ApplicationController
