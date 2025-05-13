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
end
