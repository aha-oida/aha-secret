require 'spec_helper'
require_relative '../../app/lib/app_config'

RSpec.describe AppConfig do

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
    ENV['APP_CONFIG_CLEANUP_SCHEDULE'] = '10m'
    AppConfig.reload!('test')
    expect(AppConfig.cleanup_schedule).to eq('10m')
    ENV.delete('APP_CONFIG_CLEANUP_SCHEDULE')
  end

  it 'raises error if config file is missing' do
    allow(File).to receive(:exist?).and_return(false)
    expect { AppConfig.load!('test') }.to raise_error(/Config file not found/)
  end

  it 'raises error if required config key is missing' do
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'rate_limit' => 1 } })
    expect { AppConfig.load!('test') }.to raise_error(/Missing required config keys/)
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
    allow(YAML).to receive(:load_file).and_return({ 'test' => { 'max_msg_length' => nil, 'rate_limit' => 1, 'rate_limit_period' => 1, 'cleanup_schedule' => '1m', 'url' => '/', 'default_locale' => 'en', 'custom' => {} } })
    AppConfig.reload!('test')
    expect(AppConfig.calc_max_length).to eq(20_000)
  end
end
