# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/aha_secret/version'

RSpec.describe 'AhaSecret::VERSION' do
  describe 'version loading' do
    it 'loads a version string' do
      expect(AhaSecret::VERSION).to be_a(String)
      expect(AhaSecret::VERSION).not_to be_empty
    end

    it 'returns a valid version format' do
      # Should match git describe format or "unknown"
      # Examples: v1.2.2-2-g7c6cee5, v1.2.2-0-g1234567, unknown
      expect(AhaSecret::VERSION).to match(/^(v\d+\.\d+\.\d+(-\d+-g[a-f0-9]{7})?(-dirty)?|unknown)$/)
    end

    context 'in production with VERSION file' do
      let(:version_rb_path) { File.expand_path('../lib/aha_secret/version.rb', __dir__) }
      # This is the actual path that version.rb calculates from its __dir__
      let(:version_file_path) { File.expand_path('../../VERSION', File.dirname(version_rb_path)) }

      it 'reads from VERSION file when it exists' do
        # Mock File.exist? and File.read to simulate production environment
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(version_file_path).and_return(true)
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(version_file_path).and_return("v9.9.9-0-gtest123\n")

        # Remove and reload the constant to test with mocked File methods
        AhaSecret.send(:remove_const, :VERSION) if AhaSecret.const_defined?(:VERSION)
        load version_rb_path

        # Now test the actual VERSION constant with mocked file reading
        expect(AhaSecret::VERSION).to eq('v9.9.9-0-gtest123')
      end

      it 'falls back to git when VERSION file does not exist' do
        # Mock File.exist? to return false, simulating development environment
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(version_file_path).and_return(false)

        # Remove and reload the constant
        AhaSecret.send(:remove_const, :VERSION) if AhaSecret.const_defined?(:VERSION)
        load version_rb_path

        # Should fall back to git describe
        expect(AhaSecret::VERSION).to match(/^(v\d+\.\d+\.\d+|unknown)/)
      end
    end
  end
end
