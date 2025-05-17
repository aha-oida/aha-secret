# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'
require 'rack/attack'
require 'dalli'

if ENV.include? 'MEMCACHE'
  use Rack::Attack
  options = { namespace: 'app_v1' }
  Rack::Attack.cache.store = Dalli::Client.new(ENV.fetch('MEMCACHE'), options)

  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    ['127.0.0.1', '::1'].include?(req.ip)
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

# Sequel migration check (raise if migrations are pending)
if defined?(Sequel)
  require 'sequel/extensions/migration'
  migrations_dir = File.expand_path('db/migrate', __dir__)
  if Sequel::Migrator.is_current?(DB, migrations_dir) == false
    abort 'ERROR: There are pending Sequel migrations. Please run `bundle exec rake db:migrate`.'
  end
end

run ApplicationController
