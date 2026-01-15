feature 'Index Focus', type: :feature, js: true do
  scenario 'Message textarea receives focus on page load' do
    visit '/'
    
    # Check if the message textarea has focus
    focused_element = page.evaluate_script('document.activeElement.id')
    expect(focused_element).to eq 'message'
  end
end
