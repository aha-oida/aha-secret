# frozen_string_literal: true

require_relative 'spec_helper'

describe Bin do
  it 'new bin gets random_id' do
    bin = Bin.new(payload: 'Hello, World!')
    expect(bin.save).to be true
    expect(bin.random_id).not_to be nil
  end

  it 'does not save a new bin without a payload' do
    bin = Bin.new(payload: '')
    expect(bin.save).to be false
  end
end
