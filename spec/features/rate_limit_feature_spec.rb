# frozen_string_literal: true

require 'spec_helper'

if ENV['CI']
  feature 'Rate Limiting', type: :feature, driver: :playwright do
    before(:each) do
      require 'dalli'
      Dalli::Client.new(ENV['MEMCACHE'] || 'localhost:11211', namespace: 'app_v1').flush
      # Override rate limit for this test only
      Rack::Attack.throttles.clear
      Rack::Attack.throttle('requests by ip', limit: 3, period: 60) { |req| req.ip }
    end

    after(:each) do
      # Reset throttles to default after this test
      Rack::Attack.throttles.clear
      Rack::Attack.throttle('requests by ip', limit: 64, period: 60) { |req| req.ip }
    end

    scenario 'block after 3 requests from the same IP' do
      # The browser loads assets on each visit, so the actual number of requests per visit is higher.
      # To ensure the test is robust, we allow 3 visits and expect the 4th to be blocked.
      3.times do |i|
        visit '/'
        expect(page.status_code).not_to eq(429)
      end
      visit '/'
      expect(page.status_code).to eq(429)
      expect(page).to have_content(/Rate limit exceeded|429|Retry later/)
    end
  end
end
