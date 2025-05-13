feature 'Create Bin', type: :feature, driver: :playwright do
  scenario 'User creates a bin that is exact max size chars' do
    visit '/'
    fill_in 'bin[payload]', with: SecureRandom.alphanumeric(AppConfig.max_msg_length)
    click_button 'Create Secret'
    secret_url = find_by_id('secret-url', visible: true).value # waits for the element to be present
    expect(secret_url).to include '/bins/'
  end

  scenario 'User creates a new bin' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    click_button 'Create Secret'
    secret_url = find_by_id('secret-url', visible: true).value # waits for the element to be present
    expect(secret_url).to include '/bins/'
  end

  scenario 'User creates a new bin and reveals with wrong link' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    click_button 'Create Secret'
    secret_url = find('#secret-url').value
    visit secret_url + 'wrong'

    click_button 'Reveal'
    expect(page).to have_content 'This message was deleted from the server'
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

  scenario 'User creates a bin and reveals with wrong password' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    check 'Set additional password'
    fill_in 'add-password', with: 'asdf'
    send_keys :tab

    click_button 'Create Secret'
    secret_url = find('#secret-url').value
    visit secret_url

    fill_in 'passwd', with: 'wrong'
    send_keys :tab
    click_button 'Unlock'
    expect(page).to have_content 'Decryption error'
  end

  scenario 'User creates and reveals a bin with password' do
    visit '/'
    fill_in 'bin[payload]', with: 'Hello, World!'
    check 'Set additional password'
    fill_in 'add-password', with: 'asdf'
    send_keys :tab

    click_button 'Create Secret'
    secret_url = find('#secret-url').value
    visit secret_url

    fill_in 'passwd', with: 'asdf'
    send_keys :tab
    click_button 'Unlock'
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq 'Hello, World!'
  end

  scenario 'User pastes content exceeding max allowed characters' do
    visit '/'
    textarea = find('textarea[name="bin[payload]"]')

    # Simulate pasting content that exceeds the maxlength
    max_length = textarea[:maxlength].to_i
    oversized_content = 'a' * (max_length + 1)

    # Use JavaScript to simulate the paste event
    page.execute_script(<<~JS, oversized_content)
      const textarea = document.querySelector('textarea[name="bin[payload]"]');
      const event = new ClipboardEvent('paste', {
        clipboardData: new DataTransfer()
      });
      event.clipboardData.setData('text', arguments[0]);
      textarea.dispatchEvent(event);
    JS

    # Ensure the content was not pasted
    expect(textarea.value.length).to be <= max_length
  end
end
