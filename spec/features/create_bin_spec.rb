feature 'Create Bin', type: :feature, driver: :playwright do
  scenario 'User creates a new bin' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    click_button 'Create Secret'
    expect(page).to have_content 'Create another secret'
  end

  scenario 'User creates and reveals a bin' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    click_button 'Create Secret'
    secret_url = find('#secret-url').value
    visit secret_url

    click_button 'Reveal'
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq 'Hello, World!'
  end
end
