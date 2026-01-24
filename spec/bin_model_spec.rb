# frozen_string_literal: true

require_relative 'spec_helper'

describe Bin do
  it 'new bin gets id' do
    bin = Bin.new(payload: 'Hello, World!')
    expect { bin.save }.not_to raise_error
    expect(bin.id).not_to be nil
  end

  it 'does not save a new bin without a payload' do
    bin = Bin.new(payload: '')
    expect { bin.save }.to raise_error(Sequel::ValidationFailed)
  end

  it 'does not save a new bin without an expire_date' do
    bin = Bin.new(payload: 'Hello, World!', expire_date: nil)
    expect { bin.save }.to raise_error(Sequel::ValidationFailed)
  end

  it 'has a expire_date' do
    bin = Bin.new(payload: 'Hello, World!')
    expect { bin.save }.not_to raise_error
    expect(bin.expire_date).not_to be nil
  end

  it 'has a expired? method' do
    bin = Bin.create(payload: 'Hello, World!')
    expect(bin.expired?).to be false
    bin.update(expire_date: Time.now.utc - 1*24*60*60)
    expect(bin.expired?).to be true
  end

  it 'must not have an expire_date greater than 7days' do
    expect {
      Bin.create(payload: "Hello!", expire_date: Time.now.utc + 8*24*60*60)
    }.to raise_error(Sequel::ValidationFailed)
  end

  it 'can be filtered by expiration' do
    bin = Bin.create(payload: 'Hello, World!')
    expect(Bin.expired.all).to eq []
    bin.update(expire_date: Time.now.utc - 1*24*60*60)
    expect(Bin.expired.all.map(&:id)).to eq [bin.id]
  end

  it 'has a cleanup method' do
    bin = Bin.create(payload: 'Hello, World!')
    bin.update(expire_date: Time.now.utc - 1*24*60*60)
    expect(Bin.expired.all.map(&:id)).to eq [bin.id]
    Bin.cleanup!
    expect(Bin.expired.all).to eq []
  end

  it 'has a has_password? method' do
    bin = Bin.create(payload: 'Hello, World!')
    # expect a method
    expect(bin).to respond_to(:has_password?)
  end

  it 'has a has_password? method that returns true if the password is in the payload' do
    bin = Bin.create(payload: 'Hello, World!', has_password: true)
    expect(bin.has_password?).to be true
  end

  it 'has a has_password? method that returns false if the password is not in the payload' do
    bin = Bin.create(payload: 'Hello World!')
    expect(bin.has_password?).to be false
  end
end
