# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'

# Migration check is done in config/environment.rb via Sequel::Migrator.check_current

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

run ApplicationController
