# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'

ActiveRecord::Migration.check_all_pending!

if ENV.include? 'MEMCACHE'
  use Rack::Attack
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(ENV.fetch('MEMCACHE'), options)

  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  Rack::Attack.throttle('requests by ip', limit: 15, period: 1.minutes, &:ip)
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

run ApplicationController
