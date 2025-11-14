feature 'JavaScript Security in Secrets', type: :feature, js: true do

    scenario 'Proof of concept: XSS detection works when script actually executes' do
    visit '/'

    # For this proof-of-concept, override and call alert in the same JS context
    page.execute_script(<<~JS)
      window.xssDetected = false;
      window.xssMessage = null;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.xssDetected = true;
        window.xssMessage = msg;
        return window.originalAlert(msg);
      };
      alert('Test XSS execution for detection proof');
    JS

    # Verify our detection mechanism caught the execution
    xss_detected = page.evaluate_script('window.xssDetected')
    xss_message = page.evaluate_script('window.xssMessage')

    expect(xss_detected).to be true
    expect(xss_message).to eq 'Test XSS execution for detection proof'
  end

  # real tests to show that XSS does NOT execute start here
  # Helper methods to reduce duplication
  def override_alert(var_name)
    page.execute_script(<<~JS)
      window.#{var_name} = false;
      window.originalAlert = window.alert;
      window.alert = function(msg) {
        window.#{var_name} = true;
        window.#{var_name}Message = msg;
        return window.originalAlert(msg);
      };
    JS
  end

  def setup_xss_detection
    override_alert('xssDetected')
  end

  def setup_alert_detection
    override_alert('alertCalled')
  end

  def create_secret(payload, password: nil)
    visit '/'
    fill_in 'bin[payload]', with: payload

    if password
      page.execute_script("document.getElementById('has_password').click()")
      expect(page).to have_field('add-password', visible: true)
      fill_in 'add-password', with: password
    end

    click_button 'Create Secret'
    find('#secret-url').value
  end

  def reveal_secret(secret_url, password: nil)
    visit secret_url

    if password
      fill_in 'passwd', with: password
      click_button 'Unlock'
    else
      click_button 'Reveal'
    end

    expect(page).to have_css('#dec-msg', visible: true)
    find('#dec-msg').value
  end

  def verify_no_xss_detected
    xss_detected = page.evaluate_script('window.xssDetected || false')
    expect(xss_detected).to be_falsey
  end

  def verify_no_alert_called
    alert_called = page.evaluate_script('window.alertCalled || false')
    expect(alert_called).to be_falsey
  end



  let(:js_alert_payload) { "alert('XSS executed!');" }
  let(:script_tag_payload) { '<script>alert("XSS via script tag");</script>' }
  let(:img_onerror_payload) { '<img src="x" onerror="alert(\'XSS via event handler\')">' }
  let(:password_payload) { "alert('XSS in password protected secret');" }
  let(:textarea_breakout_payload) { '</textarea><script>alert("Broke out of textarea!");</script><textarea>' }

  def script_tags_in_dom
    page.all('script', visible: :all).map(&:text)
  end

  def script_tag_content_in_dom
    page.evaluate_script('Array.from(document.querySelectorAll("script")).map(s => s.textContent).join(" ")')
  end

  def img_elements_in_dom
    page.evaluate_script('Array.from(document.querySelectorAll("img")).filter(img => img.src.includes("x") || img.outerHTML.includes("onerror"))')
  end

  scenario 'JavaScript alert in secret payload does not execute' do
    secret_url = create_secret(js_alert_payload)
    visit secret_url
    setup_alert_detection

    decrypted_secret = reveal_secret(secret_url)
    expect(decrypted_secret).to eq js_alert_payload
    verify_no_alert_called

    # Additional verification: check that no script tags are in the DOM
    expect(script_tags_in_dom.any? { |script| script == js_alert_payload }).to be false
  end

  scenario 'HTML script tag in secret payload does not execute' do
    secret_url = create_secret(script_tag_payload)
    visit secret_url
    setup_alert_detection

    decrypted_secret = reveal_secret(secret_url)
    expect(decrypted_secret).to eq script_tag_payload
    verify_no_alert_called

    # Verify script tag was not executed by checking DOM
    page.save_screenshot('tmp/script_tag_xss_test.png', full: true)
    expect(script_tag_content_in_dom).not_to include('XSS via script tag')
  end

  scenario 'JavaScript with event handlers in secret payload does not execute' do
    secret_url = create_secret(img_onerror_payload)
    visit secret_url
    setup_xss_detection

    # Also monitor for any error events that might trigger
    page.execute_script(<<~JS)
      window.addEventListener('error', function(e) {
        if (e.target && e.target.tagName === 'IMG') {
          window.imgErrorTriggered = true;
        }
      });
    JS

    decrypted_secret = reveal_secret(secret_url)
    expect(decrypted_secret).to eq img_onerror_payload
    verify_no_xss_detected

    # Verify no img error event was triggered from malicious payload
    img_error_triggered = page.evaluate_script('window.imgErrorTriggered || false')
    expect(img_error_triggered).to be_falsey

    # Verify no img elements were created from the payload
    expect(img_elements_in_dom).to be_empty
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
    secret_url = create_secret(password_payload, password: 'testpassword')
    visit secret_url
    setup_alert_detection

    decrypted_secret = reveal_secret(secret_url, password: 'testpassword')
    expect(decrypted_secret).to eq password_payload
    verify_no_alert_called
  end

  scenario 'Incorrect password for password-protected secret does not expose or execute payload' do
    secret_url = create_secret(password_payload, password: 'testpassword')
    visit secret_url
    setup_alert_detection

    # Enter incorrect password and attempt to unlock
    fill_in 'passwd', with: 'wrongpassword'
    click_button 'Unlock'

    # The secret should not be revealed
    expect(page).not_to have_css('#dec-msg', visible: true)

    # Check for error message (match actual message)
    expect(page).to have_content(/decryption error\. is the password correct\?/i)

    # Verify no alert was triggered during the failed unlock attempt
    verify_no_alert_called
  end

  scenario 'Verify textarea properly escapes content and prevents DOM manipulation' do
    secret_url = create_secret(textarea_breakout_payload)
    visit secret_url
    setup_alert_detection

    decrypted_secret = reveal_secret(secret_url)
    expect(decrypted_secret).to eq textarea_breakout_payload

    # Verify no additional script elements were created
    malicious_scripts = page.evaluate_script('Array.from(document.querySelectorAll("script")).filter(script => script.textContent.includes("Broke out of textarea!"))')
    expect(malicious_scripts).to be_empty

    # Verify the textarea element is still properly formed
    textarea_element = find('#dec-msg')
    expect(textarea_element.tag_name).to eq 'textarea'
    expect(textarea_element[:readonly]).to be_truthy

    # Verify no alert was triggered
    verify_no_alert_called
  end
end
