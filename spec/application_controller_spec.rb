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
  end

  it 'does not save a new bin without a payload' do
    post '/', bin: { payload: '' }
    expect(last_response.status).to eq(422)
    expect(Bin.count).to eq(0)
  end

  it 'shows a bin' do
    bin = Bin.create(payload: 'Hello, World!')
    get "/#{bin.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Hello, World!')
  end
end
