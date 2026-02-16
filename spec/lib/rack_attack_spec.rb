# frozen_string_literal: true

require 'spec_helper'
require 'rack/attack'

describe 'Rack::Attack throttle options' do
  after do
    Rack::Attack.throttles.clear
  end

  it 'raises error when limit is nil' do
    expect do
      Rack::Attack.throttle('test-limit-nil', limit: nil, period: 60) { |_req| '1.2.3.4' }
    end.to raise_error(ArgumentError)
  end

  it 'raises error when period is nil' do
    expect do
      Rack::Attack.throttle('test-period-nil', limit: 10, period: nil) { |_req| '1.2.3.4' }
    end.to raise_error(ArgumentError)
  end

  it 'raises error when limit and period are nil' do
    expect do
      Rack::Attack.throttle('test-both-nil', limit: nil, period: nil) { |_req| '1.2.3.4' }
    end.to raise_error(ArgumentError)
  end
end
