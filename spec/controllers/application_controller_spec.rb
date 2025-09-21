# frozen_string_literal: true

require_relative '../spec_helper'
require 'rack/test'

RSpec.describe ApplicationController, type: :controller do
  include Rack::Test::Methods

  def app
    ApplicationController.new
  end

  describe '#browser_locale' do
    let(:controller) { app }

    it 'returns supported locale from Accept-Language header (good input)' do
      env = { 'HTTP_ACCEPT_LANGUAGE' => 'de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7' }
      req = Rack::Request.new(env)
      expect(controller.send(:browser_locale, req)).to eq('de')
    end

    it 'returns nil for unsupported locale' do
      env = { 'HTTP_ACCEPT_LANGUAGE' => 'fr-FR,fr;q=0.9' }
      req = Rack::Request.new(env)
      expect(controller.send(:browser_locale, req)).to be_nil
    end

    it 'returns nil for malformed header (bad input)' do
      env = { 'HTTP_ACCEPT_LANGUAGE' => '!!!,@@@' }
      req = Rack::Request.new(env)
      expect(controller.send(:browser_locale, req)).to be_nil
    end

    it 'returns supported locale even with uppercase and whitespace' do
      env = { 'HTTP_ACCEPT_LANGUAGE' => ' DE-de  , en-US;q=0.8 ' }
      req = Rack::Request.new(env)
      expect(controller.send(:browser_locale, req)).to eq('de')
    end

    it 'returns nil if header is missing' do
      env = {}
      req = Rack::Request.new(env)
      expect(controller.send(:browser_locale, req)).to be_nil
    end
  end
end
