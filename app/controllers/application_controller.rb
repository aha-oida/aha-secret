# frozen_string_literal: true

require 'rufus-scheduler'
require 'debug'
require 'sprockets'
require 'sprockets-helpers'

# write documentation
class ApplicationController < Sinatra::Base
  set :sprockets, Sprockets::Environment.new(root)
  set :assets_prefix, '/assets'
  set :digest_assets, true

  set :erubis, escape_html: true

  I18n.config.available_locales = %i[en de]
  I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
  I18n.load_path = Dir[File.join(File.dirname(__FILE__), '..', '..', 'config', 'locales', '*.yml')]
  I18n.backend.load_translations

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :layout, true
    enable :logging
    enable :sessions
    # Setup Sprockets
    sprockets.append_path File.join(root, 'assets', 'stylesheets')
    sprockets.append_path File.join(root, 'assets', 'javascripts')
    sprockets.append_path File.join(root, 'assets', 'images')

    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = assets_prefix
      config.digest      = digest_assets
      config.public_path = public_folder

      # Force to debug mode in development mode
      # Debug mode automatically sets
      # expand = true, digest = false, manifest = false
      config.debug       = true if development?
    end

    before do
      @authenticity_token = Rack::Protection::AuthenticityToken.token(env['rack.session'])
      I18n.locale = ENV['APP_LOCALE'] || AppConfig.default_locale || I18n.default_locale
    end

    unless ENV['SKIP_SCHEDULER'] == 'true'
      Rufus::Scheduler.s.interval AppConfig.cleanup_schedule do
        Bin.cleanup!
      end
    end
  end

  get '/' do
    erb :index, locals: { max_msg_length: AppConfig.max_msg_length }
  end

  # This will be a ajax call
  post '/' do
    bin = Bin.new(bin_params)
    retention_minutes = params[:retention]&.to_i
    if retention_minutes&.positive?
      bin.expire_date = Time.now.utc + (retention_minutes * 60)
      params.delete(:retention)
    end
    begin
      bin.save
    rescue Sequel::ValidationFailed
      status 422
      return body json({ msg: bin.errors.full_messages })
    end
    json({ id: bin.id, url: bin_retrieval_url(bin) })
  end

  get '/bins/:id' do
    @bin = Bin[params[:id]]
    return status 404 unless @bin&.id

    erb :show
  end

  not_found do
    status 404
    erb :notfound
  end

  patch '/bins/:id/reveal' do
    bin = Bin[params[:id]]
    return status 422 unless bin&.id

    payload = bin.payload
    has_password = bin.has_password
    bin.destroy
    json({ payload:, has_password: })
  end

  private

  def bin_params
    allowed_keys = %w[payload has_password]
    params['bin'].slice(*allowed_keys)
  end

  helpers do
    include Sprockets::Helpers
    include Helpers
  end
end
