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
    post '/', bin: { payload: 'a'}, retention: '10081'
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
    bin = Bin.create(payload: 'Hello, World!', expire_date: Time.now - 1)
    expect(Bin.count).to eq(1)
    sleep 3 # rufus scheduler runs every 2 seconds in TEST environment
    get '/'
    expect(Bin.count).to eq(0)
  end

  # helper methods
  it 'reduces params to only payload, password and retention' do
    params = Sinatra::IndifferentHash.new.merge!(bin: { payload: 'Hello', has_password: 'true', some: 'value', foo: 'bar' }, retention: '10080', other: 'value')
    reduced_params = app.helpers.reduce_params(params)
    expected_params = Sinatra::IndifferentHash.new.merge!(bin: { payload: 'Hello', has_password: 'true' }, retention: '10080' )
    expect(reduced_params).to eq(expected_params)
  end
end
