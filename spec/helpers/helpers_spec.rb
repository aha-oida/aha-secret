RSpec.describe Helpers do
  include Helpers

  let(:request) { double('request', env: env) }

  context '#browser_locale' do
    let(:env) { { 'HTTP_ACCEPT_LANGUAGE' => 'de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7' } }
    it 'returns supported locale from Accept-Language header' do
      expect(browser_locale(request)).to eq('de')
    end

    it 'returns nil for unsupported locale' do
      env['HTTP_ACCEPT_LANGUAGE'] = 'fr-FR,fr;q=0.9'
      expect(browser_locale(request)).to be_nil
    end

    it 'returns nil for malformed header' do
      env['HTTP_ACCEPT_LANGUAGE'] = '!!!,@@@'
      expect(browser_locale(request)).to be_nil
    end

    it 'returns supported locale even with uppercase and whitespace' do
      env['HTTP_ACCEPT_LANGUAGE'] = ' DE-de  , en-US;q=0.8 '
      expect(browser_locale(request)).to eq('de')
    end

    it 'returns nil if header is missing' do
      allow(request).to receive(:env).and_return({})
      expect(browser_locale(request)).to be_nil
    end

    it 'returns nil if header is present but empty' do
      env['HTTP_ACCEPT_LANGUAGE'] = ''
      expect(browser_locale(request)).to be_nil
    end

    it 'returns nil if request is nil' do
      expect(browser_locale(nil)).to be_nil
    end

    it 'returns nil if request.env is nil' do
      req = double('request', env: nil)
      expect(browser_locale(req)).to be_nil
    end
  end
end
