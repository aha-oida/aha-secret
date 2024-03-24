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

    if @bin.save
      #content_type :json
      #{ id: @bin.id }.to_json
      erb :create
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
