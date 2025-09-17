# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Language Switching Feature', type: :feature do
  describe 'language selector UI' do
    it 'shows language selector on the main page' do
      visit '/'
      expect(page).to have_select('language-select')
      expect(page).to have_css('#language-selector')
    end

    it 'displays correct language options' do
      visit '/'
      within '#language-select' do
        expect(page).to have_content('en')
        expect(page).to have_content('de')
      end
    end

    it 'language selector has correct option values' do
      visit '/'
      expect(page).to have_select('language-select', with_options: ['en', 'de'])
    end
  end
end