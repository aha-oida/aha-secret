# frozen_string_literal: true

require 'spec_helper'

if ENV['CI']
  feature 'Rate Limiting', type: :feature, js: true do
    before(:all) do
      Rack::Attack.enabled = true
    end
    after(:all) do
      Rack::Attack.enabled = false
    end

    before(:each) do
      require 'dalli'
      Dalli::Client.new(AppConfig.memcache_url || 'localhost:11211', namespace: 'app_v1').flush
      # Set REMOTE_ADDR for all requests in this scenario (works for all requests, including assets)
      if page.driver.respond_to?(:browser)
        # cuprite: set extra HTTP headers for all requests
        page.driver.add_headers('REMOTE_ADDR' => '1.2.3.4')
      end
    end

    scenario 'block after 3 requests from the same IP' do
      # The browser loads assets on each visit, so the actual number of requests per visit is higher.
      # To ensure the test is robust, we allow only 1 visit and expect the 2nd to be blocked.
      visit '/'
      expect(page.status_code).not_to eq(429)
      visit '/'
      expect(page.status_code).to eq(429)
      expect(page).to have_content(/Rate limit exceeded|429|Retry later/)
    end

    scenario 'rate limit resets after period expiration' do
      require 'timecop'
      visit '/'
      expect(page.status_code).to eq(200)
      visit '/'
      expect(page.status_code).to eq(429)

      # Travel forward in time to after the rate limit period
      Timecop.travel(Time.now + 61)
      visit '/'
      expect(page.status_code).to eq(200)
      Timecop.return
    end

    # TODO - after PR #261 is merged
    # scenario 'custom rate limit can be set with ENV variable' do
  end
end
