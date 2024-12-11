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

  scenario 'User creates and reveals a bin with password' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    check 'Set additional password'
    fill_in 'add-password', with: 'asdf'
    send_keys :tab

    click_button 'Create Secret'
    secret_url = find('#secret-url').value
    execute_script('console.log("' + secret_url + '")')
    visit secret_url

    fill_in 'passwd', with: 'asdf'
    send_keys :tab
    click_button 'Unlock'
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq 'Hello, World!'
  end
end
