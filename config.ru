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

  rack_env_test = ENV['RACK_ENV'] == 'test'

  Rack::Attack.safelist('allow from localhost') do |req|
    allow_local = ['127.0.0.1', '::1'].include?(req.ip)
    allow_local && !rack_env_test
  end
  throttle_limit = rack_env_test ? 3 : AppConfig.rate_limit

  Rack::Attack.throttle('requests by ip', limit: throttle_limit, period: AppConfig.rate_limit_period) do |req|
    if rack_env_test && req.env['REMOTE_ADDR']
      req.env['REMOTE_ADDR']
    else
      req.ip
    end
  end
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
