feature 'Index Focus', type: :feature, js: true do
  scenario 'User visits index and message textarea receives focus' do
    visit '/'

    # Check if the message textarea has focus
    focused_element = page.evaluate_script('document.activeElement.id')
    expect(focused_element).to eq 'message'
  end
end
