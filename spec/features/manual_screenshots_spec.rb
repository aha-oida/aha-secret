feature 'Manual screenshot flow', type: :feature, js: true, screenshots: true do
  scenario 'Create secret, copy link, and reveal secret' do
    visit '/'
    expect(page).to have_selector('#message', visible: true)
    page.save_screenshot(File.join(Capybara.save_path, 'manual-01-landing.png'), full: true)

    fill_in 'bin[payload]', with: 'This is a manual CI screenshot flow secret.'
    click_button 'Create Secret'

    expect(page).to have_selector('#secret-url', visible: true)
    secret_url = find('#secret-url', visible: true).value
    expect(secret_url).to include('/bins/')
    page.save_screenshot(File.join(Capybara.save_path, 'manual-02-created-secret.png'), full: true)

    page.execute_script(<<~JS)
      Object.defineProperty(navigator, 'clipboard', {
        configurable: true,
        value: {
          writeText: function() { return Promise.resolve(); }
        }
      });
    JS

    click_button 'copy-button'
    expect(page).to have_content(/copied|copy/i)
    page.save_screenshot(File.join(Capybara.save_path, 'manual-03-copy-link.png'), full: true)

    visit secret_url
    expect(page).to have_button('Reveal')
    page.save_screenshot(File.join(Capybara.save_path, 'manual-04-before-reveal.png'), full: true)

    click_button 'Reveal'
    expect(page).to have_selector('#dec-msg', visible: true)
    expect(find('#dec-msg').value).to eq 'This is a manual CI screenshot flow secret.'
    page.save_screenshot(File.join(Capybara.save_path, 'manual-05-after-reveal.png'), full: true)
  end
end
