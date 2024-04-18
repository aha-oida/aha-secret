# frozen_string_literal: true

require './config/environment'

if ActiveRecord::Base.connection.migration_context.needs_migration?
  raise 'Migrations are pending. Run `rake db:migrate` to resolve the issue.'
end

use Rack::MethodOverride

require 'rack/protection'
use Rack::Protection, use: %i[content_security_policy], script_src: "'self'", img_src: "'self'"

run ApplicationController
