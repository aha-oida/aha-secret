# frozen_string_literal: true

require_relative 'spec_helper'

describe Bin do
  it 'new bin gets id' do
    bin = Bin.new(payload: 'Hello, World!')
    expect(bin.save).to be true
    expect(bin.id).not_to be nil
  end

  it 'does not save a new bin without a payload' do
    bin = Bin.new(payload: '')
    expect(bin.save).to be false
  end

  it 'has a expire_date' do
    bin = Bin.new(payload: 'Hello, World!')
    expect(bin.save).to be true
    expect(bin.expire_date).not_to be nil
  end

  it 'has a expired? method' do
    bin = Bin.create(payload: 'Hello, World!')
    expect(bin.expired?).to be false
    bin.update(expire_date: Time.now - 1.day)
    expect(bin.expired?).to be true
  end

  it 'must not have an expire_date greater than 7days' do
    bin = Bin.create(payload: "Hello!", expire_date: Time.now + 8.day)
    expect(bin.valid?).to be false
  end

  it 'can be filtered by expiration' do
    bin = Bin.create(payload: 'Hello, World!')
    expect(Bin.expired).to eq []
    bin.update(expire_date: Time.now - 1.day)
    expect(Bin.expired).to eq [bin]
  end

  it 'has a cleanup method' do
    bin = Bin.create(payload: 'Hello, World!')
    bin.update(expire_date: Time.now - 1.day)
    expect(Bin.expired).to eq [bin]
    Bin.cleanup
    expect(Bin.expired).to eq []
  end
end
