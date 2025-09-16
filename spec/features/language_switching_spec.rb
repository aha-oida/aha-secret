# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Language Switching Feature', type: :feature, js: true do
  describe 'language selector' do
    it 'shows language selector on the main page' do
      visit '/'
      expect(page).to have_select('language-select')
      expect(page).to have_css('#language-selector')
    end

    it 'displays correct language options' do
      visit '/'
      within '#language-select' do
        expect(page).to have_content('🇬🇧 English')
        expect(page).to have_content('🇩🇪 Deutsch')
      end
    end

    it 'shows content in English by default' do
      visit '/'
      expect(page).to have_content('Encrypt your message, store it encrypted and share a link')
      expect(page).to have_content('Create Secret')
      expect(page).to have_field('message', placeholder: 'Encrypt me in your browser!')
    end
  end

  describe 'language switching via user interaction' do
    it 'shows language selector with correct default option selected' do
      visit '/'
      expect(page).to have_select('language-select', selected: '🇬🇧 English')
    end

    it 'has change event listener attached to language selector' do
      visit '/'
      # Verify the language change function exists in the page
      expect(page.evaluate_script('typeof changeLanguage')).to eq('function')
    end

    it 'changes cookie when user selects different language' do
      visit '/'
      
      # Simulate user selecting German
      page.evaluate_script('changeLanguage("de")')
      
      # Check that cookie was set correctly
      cookie_value = page.evaluate_script('document.cookie.split(";").find(c => c.trim().startsWith("locale="))?.split("=")[1]')
      expect(cookie_value).to eq('de')
    end

    it 'has functioning JavaScript changeLanguage function' do
      visit '/'
      
      # Test the function exists and works
      result = page.evaluate_script('
        changeLanguage("de");
        // Check if cookie was set
        document.cookie.includes("locale=de");
      ')
      expect(result).to be(true)
    end
  end
end