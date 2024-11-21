# frozen_string_literal: true

require_relative 'spec_helper'
include Helpers

RSpec.describe Helpers, type: :helper do
  describe '#bin_retrieval_url' do
    let(:request) { double('request', base_url: 'http://example.org') }

    it 'returns the bin retrieval url' do
      bin = Bin.new(payload: 'Hello, World!')
      expect(bin_retrieval_url(bin)).to eq("http://example.org/bins/#{bin.id}")
    end
  end

  describe '#html_title' do
    # let(:config) { double('config', custom: { title: 'Secret Bin' }) }

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
      expect(footer_content(custom:false, content:nil)).to eq("<a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}")
    end

    it 'returns the custom footer content' do
      expect(footer_content(custom:'replace', content:'Custom Content')).to eq('Custom Content')
    end

    it 'merges the custom footer content with the default footer content' do
      expect(footer_content(custom:'append', content:'Custom Content')).to eq("Custom Content <a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}")
    end
  end
end
