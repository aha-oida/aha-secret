# frozen_string_literal: true

require './config/environment'
require 'rufus-scheduler'
require_relative '../helpers/helpers'
require 'debug'

# write documentation
class ApplicationController < Sinatra::Base
  register Sinatra::ConfigFile
  config_file '../../config/config.yml'

  set :erubis, escape_html: true

  I18n.config.available_locales = %i[en de]
  I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
  I18n.load_path = Dir[File.join(settings.root, '..', '..', 'config', 'locales', '*.yml')]
  I18n.backend.load_translations

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :layout, true
    enable :logging
    enable :sessions

    before do
      @authenticity_token = Rack::Protection::AuthenticityToken.token(env['rack.session'])
      I18n.locale = ENV['APP_LOCALE'] || settings.default_locale || I18n.default_locale
    end

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
    bin = Bin.new(bin_params)

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

  private

  def bin_params
    allowed_keys = %w[payload has_password]
    params['bin'].select { |key, _| allowed_keys.include?(key) }
  end

  helpers do
    include Helpers
  end
end
