# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'AppConfig version display' do
  # Minimal valid config with only required keys
  let(:base_config) do
    {
      'rate_limit' => 65,
      'rate_limit_period' => 60,
      'cleanup_schedule' => '10m',
      'base_url' => '/',
      'default_locale' => 'en',
      'max_msg_length' => 20000,
      'session_secret' => 'test_secret',
      'memcache_url' => '',
      'custom' => {}
    }
  end

  before do
    # Reset AppConfig to ensure clean state
    AppConfig.instance_variable_set(:@config, nil)
  end

  describe 'display_version configuration' do
    context 'when display_version is set to true in config' do
      before do
        allow(YAML).to receive(:load_file).and_return('test' => base_config.merge('display_version' => true))
        AppConfig.load!('test')
      end

      it 'reads display_version as true' do
        expect(AppConfig.display_version).to eq(true)
      end
    end

    context 'when display_version is set to false in config' do
      before do
        allow(YAML).to receive(:load_file).and_return('test' => base_config.merge('display_version' => false))
        AppConfig.load!('test')
      end

      it 'reads display_version as false' do
        expect(AppConfig.display_version).to eq(false)
      end
    end

    context 'when display_version is not in config (backward compatibility)' do
      before do
        allow(YAML).to receive(:load_file).and_return('test' => base_config)
        AppConfig.load!('test')
      end

      it 'returns nil for missing display_version' do
        expect(AppConfig.display_version).to be_nil
      end
    end
  end

  describe 'display_version is optional' do
    it 'is in OPTIONAL_KEYS' do
      expect(AppConfig::OPTIONAL_KEYS).to include('display_version')
    end
  end
end
