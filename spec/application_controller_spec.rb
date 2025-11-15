# frozen_string_literal: true

require_relative 'spec_helper'
include Helpers

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
    expect(JSON.parse(last_response.body)).to include('id' => Bin.first.id)
  end

  it 'saves a new bin with a retention time of 7 days' do
    post '/', bin: { payload: 'Hello, World!' }, retention: (7*24*60).to_s
    expect(last_response.status).to eq(200)
    expect(Bin.count).to eq(1)
  end

  it 'does not save a new bin without a payload' do
    post '/', bin: { payload: '' }
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'does not save a new bin with a payload that is too long' do
    post '/', bin: { payload: 'a' * 20_001 }
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'does not save a new bin with expire_date greater than 7days' do
    # 7 days in minutes = 10080, so use 10081
    post '/', bin: { payload: 'a'}, retention: (7*24*60 + 1).to_s
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'deletes bin and returns payload on reveal' do
    bin = Bin.create(payload: 'Hello, World!')
    patch "/bins/#{bin.id}/reveal"
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include('payload' => 'Hello, World!')
    expect(Bin.count).to eq(0)
  end

  it 'shows a bin' do
    bin = Bin.create(payload: 'Hello, World!')
    get "/bins/#{bin.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("#{bin.id}")
  end

  it 'returns 404 if bin does not exist' do
    get '/bins/123'
    expect(last_response.status).to eq(404)
  end

  it 'shows a not found page' do
    get 'bins/1234'
    expect(last_response.body).to include('This entry was not found. Maybe the retention time has already expired')
  end

  it 'returns 422 if bin does not exist on reveal' do
    patch '/bins/123/reveal'
    expect(last_response.status).to eq(422)
  end

  it 'cleans up expired bins' do
    Bin.create(payload: 'Hello, World!', expire_date: Time.now.utc - 1)
    expect(Bin.count).to eq(1)
    # manually call rufus cleanup function
    Bin.cleanup
    get '/'
    expect(Bin.count).to eq(0)
  end

  it 'does not allow saving forbidden bin params' do
    post '/', bin: { payload: 'forbidden_expire_date', expire_date: Time.now - 1 }
    expect(last_response.status).to eq(200)
    new_bin = Bin.last
    expect(new_bin.payload).to eq('forbidden_expire_date')
    # validate that it didn't save the expire_date of the past
    expect(new_bin.expire_date).to be > Time.now
  end

  it 'reveal route returns information about extra password protection' do
    bin = Bin.create(payload: 'Hello World', has_password: true)
    patch "/bins/#{bin.id}/reveal"
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include('payload' => 'Hello World', 'has_password' => true)
  end
end
