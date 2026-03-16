# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/lib/app_config'

RSpec.describe AppConfig do
  # Save and restore ENV for tests that modify ENV
  around do |example|
    original_env = ENV.to_hash.dup
    begin
      example.run
    ensure
      ENV.replace(original_env)
    end
  end

  def base_config(overrides = {})
    {
      'rate_limit' => 65,
      'rate_limit_period' => 60,
      'cleanup_schedule' => '10m',
      'base_url' => '/',
      'default_locale' => 'en',
      'max_msg_length' => 20_000,
      'custom' => {},
      'memcache_url' => '',
      'session_secret' => 'abc',
      'permitted_origins' => ''
    }.merge(overrides)
  end

  def stub_config(overrides = {})
    allow(YAML).to receive(:load_file).and_return({ 'test' => base_config(overrides) })
  end

  it 'loads the test environment config with fallback to default' do
    AppConfig.load!
    expect(AppConfig.cleanup_schedule).to eq(AppConfig::Accessors::DEFAULT_CLEANUP_SCHEDULE)
    expect(AppConfig.custom['stylesheet']).to eq(true)
  end

  it 'loads custom config available as a hash' do
    AppConfig.load!
    expect(AppConfig.custom).to be_a(Hash)
    expect(AppConfig.custom['stylesheet']).to eq(true)
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
    expect(AppConfig.cleanup_schedule).to eq(AppConfig::Accessors::DEFAULT_CLEANUP_SCHEDULE)
  end

  it 'returns default max_msg_length if missing' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => base_config('max_msg_length' => nil, 'session_secret' => '123') })
    AppConfig.reload!('test')
    expect(AppConfig.calc_max_length).to eq(AppConfig::Accessors::DEFAULT_MAX_MSG_LENGTH * 2)
  end

  it 'returns 256 for calc_max_length when max_msg_length is less than 128' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100, 'rate_limit' => 1,
                                                                'rate_limit_period' => 1, 'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.calc_max_length).to eq(AppConfig::Accessors::DEFAULT_MIN_CALC_LENGTH)
  end

  it 'returns 256 for calc_max_length when max_msg_length is exactly 128' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => AppConfig::Accessors::DEFAULT_CALC_LENGTH_THRESHOLD, 'rate_limit' => 1,
                                                                'rate_limit_period' => 1, 'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.calc_max_length).to eq(AppConfig::Accessors::DEFAULT_MIN_CALC_LENGTH)
  end

  it 'returns doubled value for calc_max_length when max_msg_length is 128 or more' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => base_config('max_msg_length' => 500, 'session_secret' => '123') })
    AppConfig.reload!('test')
    expect(AppConfig.calc_max_length).to eq(1000)
  end

  it 'returns default values for rate_limit and rate_limit_period when not configured' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => nil, 'rate_limit_period' => nil,
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.rate_limit).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT)
    expect(AppConfig.rate_limit_period).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT_PERIOD)
  end

  it 'warns and falls back to default when rate_limit is a non-numeric string' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => 'invalid', 'rate_limit_period' => 1,
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    value = nil
    expect do
      value = AppConfig.rate_limit
    end.to output(/\[CONFIG WARNING\] Expected integer but got/).to_stderr
    expect(value).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT)
  end

  it 'returns config value for rate_limit when set to negative' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => -5, 'rate_limit_period' => 1,
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.rate_limit).to eq(-5)
  end

  it 'returns config value for rate_limit when set to zero' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => 0, 'rate_limit_period' => 1,
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.rate_limit).to eq(0)
  end

  it 'warns and falls back to default when rate_limit_period is a non-numeric string' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => 1, 'rate_limit_period' => 'invalid',
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    value = nil
    expect do
      value = AppConfig.rate_limit_period
    end.to output(/\[CONFIG WARNING\] Expected integer but got/).to_stderr
    expect(value).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT_PERIOD)
  end

  it 'returns config value for rate_limit_period when set to negative' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => 1, 'rate_limit_period' => -60,
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.rate_limit_period).to eq(-60)
  end

  it 'returns config value for rate_limit_period when set to zero' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => 100,
                                                                'rate_limit' => 1, 'rate_limit_period' => 0,
                                                                'cleanup_schedule' => '1m', 'default_locale' => 'en', 'custom' => {}, 'session_secret' => '123', 'memcache_url' => '', 'base_url' => '/' } })
    AppConfig.reload!('test')
    expect(AppConfig.rate_limit_period).to eq(0)
  end

  context 'integer coercion' do
    it 'coerces numeric strings from config into integers' do
      stub_config('rate_limit' => '70', 'rate_limit_period' => '120')
      AppConfig.reload!('test')
      expect(AppConfig.rate_limit).to eq(70)
      expect(AppConfig.rate_limit_period).to eq(120)
    end

    it 'coerces numeric string max_msg_length values for calc_max_length' do
      stub_config('max_msg_length' => '150')
      AppConfig.reload!('test')
      expect(AppConfig.max_msg_length).to eq(150)
      expect(AppConfig.calc_max_length).to eq(300)
    end

    it 'coerces numeric string max_msg_length from ENV overrides' do
      stub_config
      ENV['AHA_SECRET_MAX_MSG_LENGTH'] = '300'
      AppConfig.reload!('test')
      expect(AppConfig.max_msg_length).to eq(300)
      expect(AppConfig.calc_max_length).to eq(600)
    end

    it 'warns and falls back to default when max_msg_length cannot be coerced' do
      stub_config('max_msg_length' => 'too-large')
      AppConfig.reload!('test')
      value = nil
      expect do
        value = AppConfig.max_msg_length
      end.to output(/\[CONFIG WARNING\] Expected integer but got/).to_stderr
      expect(value).to eq(AppConfig::Accessors::DEFAULT_MAX_MSG_LENGTH)

      calc_value = nil
      expect do
        calc_value = AppConfig.calc_max_length
      end.to output(/\[CONFIG WARNING\] Expected integer but got/).to_stderr
      expect(calc_value).to eq(AppConfig::Accessors::DEFAULT_MAX_MSG_LENGTH * 2)
    end

    it 'coerces numeric string ENV overrides to integers' do
      stub_config
      ENV['AHA_SECRET_RATE_LIMIT'] = '80'
      ENV['AHA_SECRET_RATE_LIMIT_PERIOD'] = '200'
      AppConfig.reload!('test')
      expect(AppConfig.rate_limit).to eq(80)
      expect(AppConfig.rate_limit_period).to eq(200)
    end

    it 'warns and falls back to defaults when ENV overrides are non-numeric' do
      stub_config('rate_limit' => 10, 'rate_limit_period' => 15)
      ENV['AHA_SECRET_RATE_LIMIT'] = 'nope'
      ENV['AHA_SECRET_RATE_LIMIT_PERIOD'] = 'nah'
      AppConfig.reload!('test')

      rl_value = nil
      expect do
        rl_value = AppConfig.rate_limit
      end.to output(/\[CONFIG WARNING\] Expected integer but got/).to_stderr
      expect(rl_value).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT)

      rlp_value = nil
      expect do
        rlp_value = AppConfig.rate_limit_period
      end.to output(/\[CONFIG WARNING\] Expected integer but got/).to_stderr
      expect(rlp_value).to eq(AppConfig::Accessors::DEFAULT_RATE_LIMIT_PERIOD)
    end
  end

  it 'returns nil for app_locale when AHA_SECRET_APP_LOCALE is not set' do
    AppConfig.reload!('test')
    expect(AppConfig.app_locale).to be_nil
  end

  it 'returns AHA_SECRET_APP_LOCALE when set' do
    ENV['AHA_SECRET_APP_LOCALE'] = 'es'
    AppConfig.reload!('test')
    expect(AppConfig.app_locale).to eq('es')
    ENV.delete('AHA_SECRET_APP_LOCALE')
  end

  it 'ignores legacy APP_LOCALE env var and warns about deprecation' do
    ENV.delete('AHA_SECRET_APP_LOCALE')
    ENV['APP_LOCALE'] = 'fr'

    expect do
      AppConfig.reload!('test')
    end.to output(/\[DEPRECATION\] ENV\['APP_LOCALE'\] is no longer supported and will be ignored; use ENV\['AHA_SECRET_APP_LOCALE'\] instead/).to_stderr

    expect(AppConfig.app_locale).to be_nil
  end

  it 'loads config from ENV for custom keys and uses ENV values' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'base_url' => '/' } })
    ENV['AHA_SECRET_BASE_URL'] = '/env-base-url'
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
    expect(AppConfig.base_url).to eq('/env-base-url')
    expect(AppConfig.permitted_origins).to eq('/env-url')
    expect(AppConfig.session_secret).to eq('env-secret')
    expect(AppConfig.memcache_url).to eq('env-memcache-url')
    expect(AppConfig.default_locale).to eq('fr')
    expect(AppConfig.rate_limit).to eq(42)
    expect(AppConfig.rate_limit_period).to eq(99)
    expect(AppConfig.cleanup_schedule).to eq('1h')
    expect(AppConfig.max_msg_length).to eq(12_345)
    expect(AppConfig.custom).to eq('{"foo": "bar"}')
    # Clean up ENV
    %w[
      AHA_SECRET_BASE_URL
      AHA_SECRET_SESSION_SECRET
      AHA_SECRET_MEMCACHE_URL
      AHA_SECRET_APP_LOCALE
      AHA_SECRET_RATE_LIMIT
      AHA_SECRET_RATE_LIMIT_PERIOD
      AHA_SECRET_CLEANUP_SCHEDULE
      AHA_SECRET_DEFAULT_LOCALE
      AHA_SECRET_MAX_MSG_LENGTH
      AHA_SECRET_CUSTOM
      AHA_SECRET_PERMITTED_ORIGINS
    ].each do |k|
      ENV.delete(k)
    end
  end

  context 'legacy ENV vars are ignored' do
    before do
      # stub minimal valid config
      allow(YAML).to receive(:load_file).and_return({ 'test' => {
                                                      'rate_limit' => 1,
                                                      'rate_limit_period' => 1,
                                                      'cleanup_schedule' => '1m',
                                                      'default_locale' => 'en',
                                                      'max_msg_length' => 100,
                                                      'custom' => {},
                                                      'memcache_url' => nil,
                                                      'session_secret' => 'abc',
                                                      'base_url' => '/',
                                                      'permitted_origins' => 'config-origin'
                                                    } })
    end

    shared_examples 'ignored legacy env var' do |legacy_var:, legacy_value:, aha_var:, reader:, expected:, unset_aha: true|
      it "warns and ignores legacy #{legacy_var} env var" do
        ENV.delete(aha_var) if unset_aha
        ENV[legacy_var] = legacy_value

        warning = "[DEPRECATION] ENV['#{legacy_var}'] is no longer supported and will be ignored; use ENV['#{aha_var}'] instead"

        expect do
          AppConfig.reload!('test')
        end.to output(/#{Regexp.escape(warning)}/).to_stderr

        expect(AppConfig.public_send(reader)).to eq(expected)
      end
    end

    include_examples 'ignored legacy env var',
                     legacy_var: 'URL',
                     legacy_value: '/legacy-url',
                     aha_var: 'AHA_SECRET_PERMITTED_ORIGINS',
                     reader: :permitted_origins,
                     expected: 'config-origin'

    include_examples 'ignored legacy env var',
                     legacy_var: 'MEMCACHE',
                     legacy_value: 'legacy-cache',
                     aha_var: 'AHA_SECRET_MEMCACHE_URL',
                     reader: :memcache_url,
                     expected: nil

    include_examples 'ignored legacy env var',
                     legacy_var: 'SESSION_SECRET',
                     legacy_value: 'legacy-secret',
                     aha_var: 'AHA_SECRET_SESSION_SECRET',
                     reader: :session_secret,
                     expected: 'abc'

    include_examples 'ignored legacy env var',
                     legacy_var: 'PERMITTED_ORIGINS',
                     legacy_value: 'legacy-origin',
                     aha_var: 'AHA_SECRET_PERMITTED_ORIGINS',
                     reader: :permitted_origins,
                     expected: 'config-origin'

    include_examples 'ignored legacy env var',
                     legacy_var: 'APP_LOCALE',
                     legacy_value: 'de',
                     aha_var: 'AHA_SECRET_APP_LOCALE',
                     reader: :app_locale,
                     expected: nil
  end

  context 'deprecated config keys' do
    shared_examples 'deprecated url config key handling' do |config_overrides:, expected_error: nil, expected_base_url: nil|
      it "handles deprecated url key with config #{config_overrides.keys.sort.join(', ')}" do
        base = base_config('memcache_url' => '', 'session_secret' => 'abc')
        # For these tests, base_url should only come from config_overrides,
        # so remove it from the base config.
        base.delete('base_url')

        allow(YAML).to receive(:load_file).and_return({ 'test' => base.merge(config_overrides) })

        warning = "[DEPRECATION] Config key 'url' is no longer supported and will be ignored; use 'base_url' instead"
        warning_regex = /#{Regexp.escape(warning)}/

        if expected_error
          expect do
            AppConfig.reload!('test')
          end.to output(warning_regex).to_stderr.and raise_error(expected_error)
        else
          expect do
            AppConfig.reload!('test')
          end.to output(warning_regex).to_stderr
          expect(AppConfig.base_url).to eq(expected_base_url)
        end
      end
    end

    include_examples 'deprecated url config key handling',
                     config_overrides: { 'url' => '/legacy-base-url' },
                     expected_error: /Missing required config keys: base_url/

    include_examples 'deprecated url config key handling',
                     config_overrides: {
                       'url' => '/legacy-base-url',
                       'base_url' => '/new-base-url'
                     },
                     expected_base_url: '/new-base-url'
  end
end
