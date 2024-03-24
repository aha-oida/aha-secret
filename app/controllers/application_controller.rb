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
      content_type :json
      { id: @bin.id }.to_json
    else
      status 422
    end
  end

  # helpers do
  #   def is_logged_in?
  #     !!session[:user_id]
  #   end

  #   def current_user
  #     User.find(session[:user_id])
  #   end
  # end
end
