# frozen_string_literal: true

require './config/environment'
require 'securerandom'
require 'rack/protection'

if ActiveRecord::Base.connection.migration_context.needs_migration?
  raise 'Migrations are pending. Run `rake db:migrate` to resolve the issue.'
end

use Rack::MethodOverride
use Rack::Session::Cookie,
    domain: ->(env) { Rack::Request.new(env).host },
    path: '/',
    expire_after: 3600 * 24,
    secret: ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
use Rack::Protection,
    use: %i[content_security_policy authenticity_token],
    script_src: "'self'",
    img_src: "'self' data:"

run ApplicationController
