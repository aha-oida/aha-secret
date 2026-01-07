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

    it 'prefers REMOTE_ADDR over req.ip in test throttling logic' do
      ENV['MEMCACHE'] = 'localhost:11211'
      allow(Dalli::Client).to receive(:new).and_return(instance_double('Dalli::Client', close: true))

      # Force config.ru to run with the modified ENV
      @app = nil
      expect { app }.not_to raise_error

      throttle = Rack::Attack.throttles['requests by ip']
      expect(throttle).not_to be_nil

      discriminator = if defined?(THROTTLE_DISCRIMINATOR)
                        expect(throttle.block).to eq(THROTTLE_DISCRIMINATOR)
                        THROTTLE_DISCRIMINATOR
                      else
                        throttle.block
                      end
      request_with_remote = double('request', env: { 'REMOTE_ADDR' => '192.168.1.100' }, ip: '127.0.0.1')
      request_without_remote = double('request', env: {}, ip: '127.0.0.1')

      expect(discriminator.call(request_with_remote)).to eq('192.168.1.100')
      expect(discriminator.call(request_without_remote)).to eq('127.0.0.1')
    end

    context 'when AppConfig returns invalid values' do
      it 'raises error when rate_limit is nil' do
        allow(AppConfig).to receive(:rate_limit).and_return(nil)
        allow(AppConfig).to receive(:rate_limit_period).and_return(nil)

        # Rack::Attack validates :period before :limit, so we expect the :period error
        expect { app }.to raise_error(ArgumentError, /Must pass :period option/)
      end

      it 'handles negative rate_limit and rate_limit_period gracefully' do
        allow(AppConfig).to receive(:rate_limit).and_return(-5)
        allow(AppConfig).to receive(:rate_limit_period).and_return(-10)

        expect { get '/' }.not_to raise_error
        expect(last_response.status).to be_between(200, 499)
      end

      it 'handles non-numeric rate_limit gracefully' do
        allow(AppConfig).to receive(:rate_limit).and_return('invalid')
        allow(AppConfig).to receive(:rate_limit_period).and_return(60)

        # String values may be coerced or cause errors
        # Test that app can be loaded without crashing during initialization
        expect { get '/' }.not_to raise_error
      end

      it 'raises error when rate_limit_period is zero (division by zero)' do
        allow(AppConfig).to receive(:rate_limit).and_return(10)
        allow(AppConfig).to receive(:rate_limit_period).and_return(0)

        # Zero period causes division by zero in rate calculations
        expect { get '/' }.to raise_error(ZeroDivisionError)
      end
    end

    context 'when memcache comes from AppConfig only' do
      around do |example|
        original_env = ENV.to_hash.dup
        ENV.delete('MEMCACHE')
        example.run
        ENV.replace(original_env)
      end

      it 'still configures the REMOTE_ADDR throttle (currently failing bug repro)' do
        allow(AppConfig).to receive(:memcache_url).and_return('memcached:11211')
        allow(Dalli::Client).to receive(:new).and_call_original

        @app = nil
        expect { app }.not_to raise_error

        throttle = Rack::Attack.throttles['requests by ip']
        expect(throttle).not_to be_nil
        expect(throttle.limit).to eq(3)
      end
    end
  end
end