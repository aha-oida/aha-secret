feature 'JavaScript Security in Secrets', type: :feature, js: true do
  scenario 'JavaScript alert in secret payload does not execute' do
    malicious_payload = "alert('XSS executed!');"

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload
    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Set up alert detection before revealing the secret
    page.execute_script(<<~JS)
      window.alertCalled = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.alertCalled = true;
        window.alertMessage = msg;
        return window.originalAlert(msg);
      };
    JS

    click_button 'Reveal'

    # Wait for decryption to complete
    expect(page).to have_css('#dec-msg', visible: true)

    # Verify the malicious payload is displayed as plain text
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq malicious_payload

    # Verify no alert was triggered
    alert_was_called = page.evaluate_script('window.alertCalled')
    expect(alert_was_called).to be false

    # Additional verification: check that no script tags are in the DOM
    script_elements = page.all('script', visible: :all).map(&:text)
    expect(script_elements.any? { |script| script == malicious_payload }).to be false
  end

  scenario 'HTML script tag in secret payload does not execute' do
    malicious_payload = '<script>alert("XSS via script tag");</script>'

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload
    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Set up alert detection
    page.execute_script(<<~JS)
      window.alertCalled = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.alertCalled = true;
        window.alertMessage = msg;
        return window.originalAlert(msg);
      };
    JS

    click_button 'Reveal'

    # Verify the malicious payload is displayed as plain text in textarea
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq malicious_payload

    # Verify no alert was triggered
    alert_was_called = page.evaluate_script('window.alertCalled')
    expect(alert_was_called).to be false

    # Verify script tag was not executed by checking DOM
    all_script_content = page.evaluate_script('Array.from(document.querySelectorAll("script")).map(s => s.textContent).join(" ")')

    # create a screenshot for manual inspection if needed
    page.save_screenshot('tmp/script_tag_xss_test.png', full: true)
    expect(all_script_content).not_to include('XSS via script tag')
  end

  scenario 'JavaScript with event handlers in secret payload does not execute' do
    malicious_payload = '<img src="x" onerror="alert(\'XSS via event handler\')">'

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload
    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Set up comprehensive JavaScript execution detection
    page.execute_script(<<~JS)
      window.xssDetected = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.xssDetected = true;
        window.xssMessage = msg;
        return window.originalAlert(msg);
      };

      // Also monitor for any error events that might trigger
      window.addEventListener('error', function(e) {
        if (e.target && e.target.tagName === 'IMG') {
          window.imgErrorTriggered = true;
        }
      });
    JS

    click_button 'Reveal'

    # Verify the payload is safely displayed as text
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq malicious_payload

    # Verify no XSS was triggered
    xss_detected = page.evaluate_script('window.xssDetected')
    expect(xss_detected).to be false

    # Verify no img error event was triggered from malicious payload
    img_error_triggered = page.evaluate_script('window.imgErrorTriggered || false')
    expect(img_error_triggered).to be false

    # Verify no img elements were created from the payload
    malicious_img_elements = page.evaluate_script('Array.from(document.querySelectorAll("img")).filter(img => img.src.includes("x") || img.outerHTML.includes("onerror"))')
    expect(malicious_img_elements).to be_empty
  end

  scenario 'Complex JavaScript payload with multiple attack vectors does not execute' do
    malicious_payload = <<~PAYLOAD.strip
      <script>alert('Script tag XSS');</script>
      <img src="x" onerror="alert('Image onerror XSS')">
      <svg onload="alert('SVG onload XSS')">
      javascript:alert('JavaScript protocol XSS')
      <iframe src="javascript:alert('Iframe XSS')"></iframe>
    PAYLOAD

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload
    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Comprehensive XSS detection setup
    page.execute_script(<<~JS)
      window.xssAttempts = [];
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.xssAttempts.push(msg);
        return window.originalAlert(msg);
      };

      // Monitor for various events that could indicate XSS
      var eventTypes = ['error', 'load'];
      for (let i = 0; i < eventTypes.length; i++) {
        let eventType = eventTypes[i];
        window.addEventListener(eventType, function(e) {
          if (e.target && ['IMG', 'SVG', 'IFRAME'].indexOf(e.target.tagName) !== -1) {
            window.xssAttempts.push(eventType + ' on ' + e.target.tagName);
          }
        }, true);
      }
    JS

    click_button 'Reveal'

    # Verify the entire malicious payload is displayed as plain text
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq malicious_payload

    # Verify no XSS attempts were successful
    xss_attempts = page.evaluate_script('window.xssAttempts || []')
    expect(xss_attempts).to be_empty

    # Verify no malicious elements were created in the DOM
    dangerous_scripts = page.evaluate_script('Array.from(document.querySelectorAll("script:not([src])")).filter(s => s.textContent.includes("XSS"))')
    dangerous_imgs = page.evaluate_script('Array.from(document.querySelectorAll("img")).filter(img => img.src === "x" || img.hasAttribute("onerror"))')
    dangerous_svgs = page.evaluate_script('Array.from(document.querySelectorAll("svg")).filter(svg => svg.hasAttribute("onload"))')
    dangerous_iframes = page.evaluate_script('Array.from(document.querySelectorAll("iframe")).filter(iframe => iframe.src.includes("javascript:"))')

    expect(dangerous_scripts).to be_empty
    expect(dangerous_imgs).to be_empty
    expect(dangerous_svgs).to be_empty
    expect(dangerous_iframes).to be_empty
  end

  scenario 'Password-protected secret with JavaScript payload does not execute' do
    malicious_payload = "alert('XSS in password protected secret');"

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload

    # Enable password protection
    page.execute_script("document.getElementById('has_password').click()")
    expect(page).to have_field('add-password', visible: true)
    fill_in 'add-password', with: 'testpassword'

    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Set up XSS detection
    page.execute_script(<<~JS)
      window.alertCalled = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.alertCalled = true;
        window.alertMessage = msg;
        return window.originalAlert(msg);
      };
    JS

    # Enter correct password and unlock
    fill_in 'passwd', with: 'testpassword'
    click_button 'Unlock'

    # Verify the malicious payload is displayed as plain text
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq malicious_payload

    # Verify no alert was triggered during the unlock/decrypt process
    alert_was_called = page.evaluate_script('window.alertCalled')
    expect(alert_was_called).to be false
  end

  scenario 'Incorrect password for password-protected secret does not expose or execute payload' do
    malicious_payload = "alert('XSS in password protected secret');"

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload

    # Enable password protection
    page.execute_script("document.getElementById('has_password').click()")
    expect(page).to have_field('add-password', visible: true)
    fill_in 'add-password', with: 'testpassword'

    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Set up XSS detection
    page.execute_script(<<~JS)
      window.alertCalled = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.alertCalled = true;
        window.alertMessage = msg;
        return window.originalAlert(msg);
      };
    JS

    # Enter incorrect password and attempt to unlock
    fill_in 'passwd', with: 'wrongpassword'
    click_button 'Unlock'

    # The secret should not be revealed
    expect(page).not_to have_css('#dec-msg', visible: true)

    # Check for error message (match actual message)
    expect(page).to have_content(/decryption error\. is the password correct\?/i)

    # Verify no alert was triggered during the failed unlock attempt
    alert_was_called = page.evaluate_script('window.alertCalled')
    expect(alert_was_called).to be false
  end

  scenario 'Verify textarea properly escapes content and prevents DOM manipulation' do
    # Test payload that could potentially break out of textarea context
    malicious_payload = '</textarea><script>alert("Broke out of textarea!");</script><textarea>'

    visit '/'
    fill_in 'bin[payload]', with: malicious_payload
    click_button 'Create Secret'
    secret_url = find('#secret-url').value

    visit secret_url

    # Set up XSS detection
    page.execute_script(<<~JS)
      window.alertCalled = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.alertCalled = true;
        return window.originalAlert(msg);
      };
    JS

    click_button 'Reveal'

    # Verify the textarea still contains the full payload as text
    decrypted_secret = find('#dec-msg').value
    expect(decrypted_secret).to eq malicious_payload

    # Verify no additional script elements were created
    malicious_scripts = page.evaluate_script('Array.from(document.querySelectorAll("script")).filter(script => script.textContent.includes("Broke out of textarea!"))')
    expect(malicious_scripts).to be_empty

    # Verify the textarea element is still properly formed
    textarea_element = find('#dec-msg')
    expect(textarea_element.tag_name).to eq 'textarea'
    expect(textarea_element[:readonly]).to be_truthy

    # Verify no alert was triggered
    alert_was_called = page.evaluate_script('window.alertCalled')
    expect(alert_was_called).to be false
  end
end