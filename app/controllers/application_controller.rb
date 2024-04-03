# frozen_string_literal: true

require './config/environment'

# write documentation
class ApplicationController < Sinatra::Base
  set :erubis, escape_html: true

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :layout, true

    # enable :sessions
    # set :session_secret, "super secret"
  end

  get '/' do
    erb :index
  end

  # This will be a ajax call
  post '/' do
    @bin = Bin.new(params[:bin])
    # calculate the expiration date - now + retention_time in minutes
    if params.dig(:retention)&.to_i&.> 0
      @bin.expire_date = Time.now + params[:retention].to_i.minutes
      params.delete(:retention)
    end

    if @bin.save
      content_type :json
      { id: @bin.random_id, url: bin_retrieval_url(@bin) }.to_json
    else
      status 422
    end
  end

  get '/bins/:id' do
    @bin = Bin.find_by_random_id(params[:id])
    erb :show
  end

  helpers do
    def bin_retrieval_url(bin)
      "#{request.base_url}/bins/#{bin.random_id}"
    end
  end
end
