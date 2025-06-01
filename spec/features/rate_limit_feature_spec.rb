# frozen_string_literal: true

require 'spec_helper'

# Debugging output for CI environment variables
puts "[DEBUG] ENV['MEMCACHE']: #{ENV['MEMCACHE']}"
puts "[DEBUG] ENV['RACK_ENV']: #{ENV['RACK_ENV']}"

if ENV['CI']
  feature 'Rate Limiting', type: :feature, driver: :playwright do
    before(:all) do
      Rack::Attack.enabled = true
    end
    after(:all) do
      Rack::Attack.enabled = false
    end

    before(:each) do
      require 'dalli'
      Dalli::Client.new(ENV['MEMCACHE'] || 'localhost:11211', namespace: 'app_v1').flush
      # Set custom header so only test requests are counted for rate limiting
      page.driver.header('X-RateLimit-Test-IP', '1.2.3.4') if page.driver.respond_to?(:header)
    end

    scenario 'block after 3 requests from the same IP' do
      # The browser loads assets on each visit, so the actual number of requests per visit is higher.
      # To ensure the test is robust, we allow 3 visits and expect the 4th to be blocked.
      3.times do |i|
        visit '/'
        puts "[DEBUG] Request \\#{i+1}: page.status_code=#{page.status_code}"
        expect(page.status_code).not_to eq(429)
      end
      visit '/'
      puts "[DEBUG] Request 4: page.status_code=#{page.status_code}"
      expect(page.status_code).to eq(429)
      expect(page).to have_content(/Rate limit exceeded|429|Retry later/)
    end
  end
end
