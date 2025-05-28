# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/lib/app_config'

RSpec.describe AppConfig do
  # Save and restore ENV for tests that modify ENV
  before(:each) do
    @original_env = ENV.to_hash.dup
  end

  after(:each) do
    ENV.replace(@original_env)
  end

  it 'loads the test environment config with fallback to default' do
    AppConfig.load!
    expect(AppConfig.cleanup_schedule).to eq('5m')
    expect(AppConfig.custom['stylesheet']).to eq(false)
  end

  it 'loads custom config available as a hash' do
    AppConfig.load!
    expect(AppConfig.custom).to be_a(Hash)
    expect(AppConfig.custom['stylesheet']).to eq(false)
  end

  it 'responds to known config keys' do
    AppConfig.load!
    expect(AppConfig.respond_to?(:max_msg_length)).to be true
  end

  it 'raises NoMethodError for unknown keys' do
    AppConfig.load!
    expect { AppConfig.unknown_key }.to raise_error(NoMethodError)
  end

  it 'supports ENV override for config values' do
    ENV['AHA_SECRET_CLEANUP_SCHEDULE'] = '10m'
    AppConfig.reload!('test')
    expect(AppConfig.cleanup_schedule).to eq('10m')
    ENV.delete('AHA_SECRET_CLEANUP_SCHEDULE')
  end

  it 'raises error if config file is missing' do
    allow(File).to receive(:exist?).and_return(false)
    expect { AppConfig.load!('test') }.to raise_error(/Config file not found/)
  end

  it 'freezes the config object to prevent mutation' do
    AppConfig.reload!('test')
    expect { AppConfig.instance_variable_get(:@config).cleanup_schedule = '20m' }.to raise_error(FrozenError)
  end

  it 'can reload config' do
    AppConfig.reload!('test')
    expect(AppConfig.cleanup_schedule).to eq('5m')
  end

  it 'returns default max_msg_length if missing' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => nil, 'rate_limit' => 1,
                                                                'rate_limit_period' => 1, 'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.calc_max_length).to eq(20_000)
  end

  it 'loads config from ENV for custom keys and uses ENV values' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'url' => '/' } })
    ENV['AHA_SECRET_PERMITTED_ORIGINS'] = '/env-url'
    ENV['AHA_SECRET_SESSION_SECRET'] = 'env-secret'
    ENV['AHA_SECRET_MEMCACHE_URL'] = 'env-memcache-url'
    ENV['AHA_SECRET_APP_LOCALE'] = 'fr'
    ENV['AHA_SECRET_RATE_LIMIT'] = '42'
    ENV['AHA_SECRET_RATE_LIMIT_PERIOD'] = '99'
    ENV['AHA_SECRET_CLEANUP_SCHEDULE'] = '1h'
    ENV['AHA_SECRET_DEFAULT_LOCALE'] = 'fr'
    ENV['AHA_SECRET_MAX_MSG_LENGTH'] = '12345'
    ENV['AHA_SECRET_CUSTOM'] = '{"foo": "bar"}'

    AppConfig.reload!('test')
    expect(AppConfig.permitted_origins).to eq('/env-url')
    expect(AppConfig.session_secret).to eq('env-secret')
    expect(AppConfig.memcache_url).to eq('env-memcache-url')
    expect(AppConfig.default_locale).to eq('fr')
    expect(AppConfig.rate_limit).to eq('42')
    expect(AppConfig.rate_limit_period).to eq('99')
    expect(AppConfig.cleanup_schedule).to eq('1h')
    expect(AppConfig.max_msg_length).to eq('12345')
    expect(AppConfig.custom).to eq('{"foo": "bar"}')
    # Clean up ENV
    %w[AHA_SECRET_URL AHA_SECRET_SESSION_SECRET AHA_SECRET_MEMCACHE_URL AHA_SECRET_APP_LOCALE AHA_SECRET_RATE_LIMIT
       AHA_SECRET_RATE_LIMIT_PERIOD AHA_SECRET_CLEANUP_SCHEDULE AHA_SECRET_DEFAULT_LOCALE AHA_SECRET_MAX_MSG_LENGTH AHA_SECRET_CUSTOM].each do |k|
      ENV.delete(k)
    end
  end

  context 'legacy ENV overrides' do
    it 'uses SESSION_SECRET env var for session_secret' do
      # Stub minimal YAML config with required keys
      allow(YAML).to receive(:load_file).and_return({ 'test' => {
                                                      'rate_limit' => 1,
                                                      'rate_limit_period' => 1,
                                                      'cleanup_schedule' => '1m',
                                                      'default_locale' => 'en',
                                                      'max_msg_length' => 100,
                                                      'custom' => {},
                                                      'memcache_url' => '',
                                                      'session_secret' => nil,
                                                      'url' => '/'
                                                    } })
      ENV['SESSION_SECRET'] = 'legacy-secret'

      AppConfig.reload!('test')
      expect(AppConfig.session_secret).to eq('legacy-secret')
    end

    it 'uses MEMCACHE env var for memcache_url' do
      allow(YAML).to receive(:load_file).and_return({ 'test' => {
                                                      'rate_limit' => 1,
                                                      'rate_limit_period' => 1,
                                                      'cleanup_schedule' => '1m',
                                                      'default_locale' => 'en',
                                                      'max_msg_length' => 100,
                                                      'custom' => {},
                                                      'memcache_url' => nil,
                                                      'session_secret' => 'abc',
                                                      'url' => '/'
                                                    } })
      ENV['MEMCACHE'] = 'legacy-memcache'

      AppConfig.reload!('test')
      expect(AppConfig.memcache_url).to eq('legacy-memcache')
    end
  end

  context 'deprecated ENV warnings' do
    before do
      # stub minimal valid config
      allow(YAML).to receive(:load_file).and_return({ 'test' => {
                                                      'rate_limit' => 1,
                                                      'rate_limit_period' => 1,
                                                      'cleanup_schedule' => '1m',
                                                      'default_locale' => 'en',
                                                      'max_msg_length' => 100,
                                                      'custom' => {},
                                                      'memcache_url' => '',
                                                      'session_secret' => 'abc',
                                                      'url' => '/'
                                                    } })
    end

    it 'warns when using deprecated URL env var' do
      ENV['URL'] = '/legacy-url'
      expect do
        AppConfig.reload!('test')
      end.to output(/\[DEPRECATION\] ENV\['URL'\] is deprecated; use ENV\['AHA_SECRET_PERMITTED_ORIGINS'\] instead/).to_stderr
      expect(AppConfig.permitted_origins).to eq('/legacy-url')
    end

    it 'warns when using deprecated MEMCACHE env var' do
      ENV['MEMCACHE'] = 'legacy-cache'
      expect do
        AppConfig.reload!('test')
      end.to output(/\[DEPRECATION\] ENV\['MEMCACHE'\] is deprecated; use ENV\['AHA_SECRET_MEMCACHE_URL'\] instead/).to_stderr
      expect(AppConfig.memcache_url).to eq('legacy-cache')
    end

    it 'warns when using deprecated SESSION_SECRET env var' do
      ENV['SESSION_SECRET'] = 'legacy-secret'
      expect do
        AppConfig.reload!('test')
      end.to output(/\[DEPRECATION\] ENV\['SESSION_SECRET'\] is deprecated; use ENV\['AHA_SECRET_SESSION_SECRET'\] instead/).to_stderr
      expect(AppConfig.session_secret).to eq('legacy-secret')
    end

    it 'warns when using deprecated PERMITTED_ORIGINS env var' do
      ENV['PERMITTED_ORIGINS'] = 'legacy-origin'
      expect do
        AppConfig.reload!('test')
      end.to output(/\[DEPRECATION\] ENV\['PERMITTED_ORIGINS'\] is deprecated; use ENV\['AHA_SECRET_PERMITTED_ORIGINS'\] instead/).to_stderr
      expect(AppConfig.permitted_origins).to eq('legacy-origin')
    end
  end
end
