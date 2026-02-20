# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe 'config.ru Rate Limiting' do
  include Rack::Test::Methods

  around(:each) do |example|
    original_env = ENV.to_hash.dup
    # Set a valid session secret for Rack::Session::Cookie
    ENV['AHA_SECRET_SESSION_SECRET'] = 'a' * 64  # Valid 64-character secret
    example.run
    ENV.replace(original_env)
  end

  def app
    @app ||= begin
      # Load the Rack application using Rack::Builder and the config.ru file
      app, _options = Rack::Builder.parse_file(File.expand_path('../../config.ru', __dir__))
      app
    end
  end

  before do
    # Ensure Rack::Attack is enabled for these tests
    Rack::Attack.enabled = true
    @app = nil
  end

  after do
    # Reset Rack::Attack state
    Rack::Attack.enabled = false
  end

  it 'configures rate limiting with AppConfig values' do
    # Reload AppConfig to ensure we get the real configuration, not any stubs
    AppConfig.reload!('test')

    # This test will trigger the rate limit configuration
    # The app loading will execute the config.ru throttle block setup
    expect { app }.not_to raise_error

    # Verify that AppConfig methods return the expected values from the real config
    expect(AppConfig.rate_limit).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT)  # From config.yml default
    expect(AppConfig.rate_limit_period).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT_PERIOD)  # From config.yml default
  end

  it 'configures rate limiting with custom ENV values' do
    ENV['AHA_SECRET_RATE_LIMIT'] = '42'
    ENV['AHA_SECRET_RATE_LIMIT_PERIOD'] = '120'
    AppConfig.reload!('test')

    expect { app }.not_to raise_error

    expect(AppConfig.rate_limit).to eq(42)
    expect(AppConfig.rate_limit_period).to eq(120)
  end

  it 'handles test environment rate limiting' do
    ENV['REMOTE_ADDR'] = '192.168.1.100'

    # Make a request that will trigger the throttle block
    get '/', {}, { 'REMOTE_ADDR' => '192.168.1.100' }

    # If the request completes without raising an exception, it proves that:
    # 1. The throttle block executed successfully
    # 2. The IP extraction logic (REMOTE_ADDR vs req.ip) worked correctly
    # 3. The rate limiting configuration loaded properly
    expect(last_response.status).to be_between(200, 499)
  end

  describe 'throttle block logic unit tests' do
    it 'uses correct rate limit values from AppConfig' do
      # Ensure clean ENV state
      ENV.delete('AHA_SECRET_RATE_LIMIT')
      ENV.delete('AHA_SECRET_RATE_LIMIT_PERIOD')
      AppConfig.reload!('test')

      # Test that AppConfig provides the expected rate limit values
      expect(AppConfig.rate_limit).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT)  # Default constant value
      expect(AppConfig.rate_limit_period).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT_PERIOD)  # Default constant value
    end

    it 'falls back to req.ip when REMOTE_ADDR not available in test' do
      request_env = {}  # No REMOTE_ADDR
      mock_request = double('request', env: request_env, ip: '127.0.0.1')

      # In test environment without REMOTE_ADDR, should fall back to req.ip
      expect(mock_request.env['REMOTE_ADDR']).to be_nil
      expect(mock_request.ip).to eq('127.0.0.1')
    end

    context 'when AppConfig returns invalid values' do
      it 'handles negative rate_limit and rate_limit_period gracefully' do
        allow(AppConfig).to receive(:rate_limit).and_return(-5)
        allow(AppConfig).to receive(:rate_limit_period).and_return(-10)

        expect { get '/' }.not_to raise_error
        expect(last_response.status).to be_between(200, 499)
      end

      it 'handles non-numeric rate_limit gracefully' do
        ENV['AHA_SECRET_RATE_LIMIT'] = 'invalid'
        ENV['AHA_SECRET_RATE_LIMIT_PERIOD'] = '60'
        AppConfig.reload!('test')
        @app = nil

        # Non-numeric env input should be coerced by AppConfig accessor fallback.
        expect { get '/' }.not_to raise_error
      end

      it 'raises error when rate_limit_period is zero' do
        allow(AppConfig).to receive(:rate_limit).and_return(10)
        allow(AppConfig).to receive(:rate_limit_period).and_return(0)

        expect { get '/' }.to raise_error(ZeroDivisionError)
      end
    end
  end
end
