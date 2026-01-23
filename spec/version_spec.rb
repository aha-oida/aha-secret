# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/aha_secret/version'

RSpec.describe 'AhaSecret::VERSION' do
  it 'is defined as a string' do
    expect(AhaSecret::VERSION).to be_a(String)
    expect(AhaSecret::VERSION).not_to be_empty
  end
end
