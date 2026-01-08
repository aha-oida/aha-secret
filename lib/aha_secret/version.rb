# frozen_string_literal: true

# AhaSecret version module
# Reads version from VERSION file (production/build) or git describe (development)
module AhaSecret
  VERSION = if File.exist?(File.expand_path('../../VERSION', __dir__))
              # Production: read from VERSION file (created during build)
              File.read(File.expand_path('../../VERSION', __dir__)).strip
            else
              # Development: read from git (always works in dev environment)
              `git describe --tags --long --always --dirty 2>/dev/null`.strip.then do |v|
                v.empty? ? 'unknown' : v
              end
            end
end
