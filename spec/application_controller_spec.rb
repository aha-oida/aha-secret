# frozen_string_literal: true

require_relative 'spec_helper'

def app
  ApplicationController
end

describe ApplicationController do
  it 'responds with a welcome message' do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('AHA-Secret')
  end

  it 'saves a new bin' do
    post '/', bin: { payload: 'Hello, World!' }
    expect(last_response.status).to eq(200)
    expect(Bin.count).to eq(1)
    expect(JSON.parse(last_response.body)).to include('id' => Bin.first.random_id)
  end

  it 'saves a new bin with a retention time of 7 days' do
    post '/', bin: { payload: 'Hello, World!' }, retention: '10080'
    expect(last_response.status).to eq(200)
    expect(Bin.count).to eq(1)
  end

  it 'does not save a new bin without a payload' do
    post '/', bin: { payload: '' }
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'does not save a new bin with a payload that is too long' do
    post '/', bin: { payload: 'a' * 10_001 }
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'does not save a new bin with expire_date greater than 7days' do
    post '/', bin: { payload: 'a', expire_date: Time.now + 8.day }
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'deletes bin and returns payload on reveal' do
    bin = Bin.create(payload: 'Hello, World!')
    patch "/bins/#{bin.random_id}/reveal"
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include('payload' => 'Hello, World!')
    expect(Bin.count).to eq(0)
  end

  it 'shows a bin' do
    bin = Bin.create(payload: 'Hello, World!')
    get "/bins/#{bin.random_id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Hello, World!')
  end
end
