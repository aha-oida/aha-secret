# frozen_string_literal: true

require './config/environment'
require 'rufus-scheduler'

# write documentation
class ApplicationController < Sinatra::Base
  register Sinatra::ConfigFile
  config_file '../../config/config.yml'

  set :erubis, escape_html: true

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :layout, true
    enable :logging

    # enable :sessions
    # set :session_secret, "super secret"
    unless defined?(IRB)
      Rufus::Scheduler.s.interval settings.cleanup_schedule do
        Bin.cleanup
      end
    end
  end

  get '/' do
    erb :index
  end

  # This will be a ajax call
  post '/' do
    bin = Bin.new(params[:bin])

    retention_minutes = params[:retention]&.to_i&.minutes
    if retention_minutes&.positive?
      bin.expire_date = Time.now + retention_minutes
      params.delete(:retention)
    end
    return status 422 unless bin.save

    content_type :json
    { id: bin.id, url: bin_retrieval_url(bin) }.to_json
  end

  get '/bins/:id' do
    @bin = Bin.find_by_id(params[:id])
    return status 404 unless @bin

    erb :show
  end

  not_found do
    status 404
    erb :notfound
  end

  patch '/bins/:id/reveal' do
    bin = Bin.find_by_id(params[:id])
    return status 422 unless bin

    payload = bin.payload
    bin.destroy
    content_type :json
    { payload: }.to_json
  end

  helpers do
    def bin_retrieval_url(bin)
      "#{request.base_url}/bins/#{bin.id}"
    end
  end
end
