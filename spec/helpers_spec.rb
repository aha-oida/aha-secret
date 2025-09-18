# frozen_string_literal: true

require_relative 'spec_helper'
include Helpers

RSpec.describe Helpers, type: :helper do

  describe '#browser_locale' do
    let(:helper) { Object.new.extend(Helpers) }
    let(:supported_locales) { %i[en de] }

    before do
      allow(I18n).to receive(:available_locales).and_return(supported_locales)
    end

    def mock_request(header)
      double('request', env: { 'HTTP_ACCEPT_LANGUAGE' => header })
    end

    it 'returns supported locale from Accept-Language header (good input)' do
      request = mock_request('de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7')
      expect(helper.browser_locale(request)).to eq('de')
    end

    it 'returns nil for unsupported locale' do
      request = mock_request('fr-FR,fr;q=0.9')
      expect(helper.browser_locale(request)).to be_nil
    end

    it 'returns nil for malformed header (bad input)' do
      request = mock_request('!!!,@@@')
      expect(helper.browser_locale(request)).to be_nil
    end

    it 'returns nil if header is missing' do
      request = double('request', env: {})
      expect(helper.browser_locale(request)).to be_nil
    end
  end
  describe '#bin_retrieval_url' do
    let(:request) { double('request', base_url: 'http://example.org') }

    it 'returns the bin retrieval url' do
      bin = double('bin', id: 1)
      expect(bin_retrieval_url(bin)).to eq("http://example.org/bins/#{bin.id}")
    end
  end

  describe '#html_title' do
    it 'returns the default title' do
      expect(html_title(custom:false, content:nil)).to eq('aha-secret: Share Secrets')
    end

    it 'returns the custom title' do
      expect(html_title(custom:'replace', content:'Custom Title')).to eq('Custom Title')
    end

    it 'returns the custom title appended to the default title' do
      expect(html_title(custom:'append', content:'Custom Title')).to eq('Custom Title | aha-secret: Share Secrets')
    end
  end

  describe '#html_meta' do
    it 'returns the default meta description' do
      expect(html_meta_description(custom:false, content:nil)).to eq('AHA-Secret is a simple and secure way to share secrets.')
    end

    it 'returns the custom meta description' do
      expect(html_meta_description(custom:'replace', content:'Custom Description')).to eq('Custom Description')
    end

    it 'merges the custom meta description with the default meta description' do
      expect(html_meta_description(custom:'append', content:'Custom Description')).to eq('Custom Description, AHA-Secret is a simple and secure way to share secrets.')
    end

    it 'returns the default meta keywords' do
      expect(html_meta_keywords(custom:false, content:nil)).to eq('secret, share, encryption, secure, simple, bin, paste, text, code')
    end

    it 'returns the custom meta keywords' do
      expect(html_meta_keywords(custom:'replace', content:'Custom Keywords')).to eq('Custom Keywords')
    end

    it 'merges the custom meta keywords with the default meta keywords' do
      expect(html_meta_keywords(custom:'append', content:'Custom Keywords')).to eq('Custom Keywords, secret, share, encryption, secure, simple, bin, paste, text, code')
    end
  end

  describe '#footer_content' do
    it 'returns the default footer content' do
      expect(footer_content(custom:false, content:nil)).to eq("<p><a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}</p>")
    end

    it 'returns the custom footer content' do
      expect(footer_content(custom:'replace', content:'Custom Content')).to eq('Custom Content')
    end

    it 'merges the custom footer content with the default footer content' do
      expect(footer_content(custom:'append', content:'Custom Content')).to eq("Custom Content <p><a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}</p>")
    end
  end
end
