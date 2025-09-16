# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Language Switching Feature', type: :feature do
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

  describe 'language switching via cookie', js: true do
    it 'shows German content when locale cookie is set to de' do
      # Set cookie using JavaScript to simulate browser behavior
      visit '/'
      page.execute_script('document.cookie = "locale=de; path=/; max-age=31536000"')
      visit '/'
      expect(page).to have_content('Verschlüssle deine Nachricht, speichere sie verschlüsselt und teile einen Link')
      expect(page).to have_content('Erstelle Nachricht')
      expect(page).to have_field('message', placeholder: 'Text hier eingeben, wird im Webbrowser verschlüsselt!')
    end

    it 'preserves language selection across page reloads' do
      # First set German via cookie and verify
      visit '/'
      page.execute_script('document.cookie = "locale=de; path=/; max-age=31536000"')
      visit '/'
      expect(page).to have_content('Verschlüssle deine Nachricht')
      
      # Reload page and verify German is still active
      visit '/'
      expect(page).to have_content('Verschlüssle deine Nachricht')
    end

    it 'falls back to English for invalid locale cookie' do
      visit '/'
      page.execute_script('document.cookie = "locale=invalid; path=/; max-age=31536000"')
      visit '/'
      expect(page).to have_content('Encrypt your message, store it encrypted and share a link')
      expect(page).to have_content('Create Secret')
    end
  end
end