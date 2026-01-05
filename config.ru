# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'

ActiveRecord::Migration.check_all_pending!

TEST_ENV = ENV['RACK_ENV'] == 'test' unless defined?(TEST_ENV)

THROTTLE_DISCRIMINATOR = if defined?(THROTTLE_DISCRIMINATOR) # idempotency
                           THROTTLE_DISCRIMINATOR
                         else
                           lambda do |req|
                             if TEST_ENV && req.env['REMOTE_ADDR']
                               req.env['REMOTE_ADDR']
                             else
                               req.ip
                             end
                           end
                         end

if AppConfig.memcache_url
  use Rack::Attack
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(AppConfig.memcache_url, options)

  Rack::Attack.safelist('allow from localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip) && !TEST_ENV
  end

  throttle_limit = TEST_ENV ? 3 : AppConfig.rate_limit

  Rack::Attack.throttle('requests by ip', limit: throttle_limit, period: AppConfig.rate_limit_period,
                        &THROTTLE_DISCRIMINATOR)
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
