require 'rails_helper'

describe 'Pages' do
  fixtures :users

  before(:each) do
    @admin = users(:captain_janeway)
    visit '/'
    fill_in 'username_or_email', with: @admin.login
    fill_in 'password', with: 'password'
    click_on 'Login'
  end

  it 'can create a new page' do
    click_link 'New Homepage'
    fill_in 'Page Title', with: 'Voyager Home'
    fill_in 'Breadcrumb', with: 'Home'
    click_button 'Create Page'

    within 'table#pages' do
      expect(page).to have_selector 'tbody tr', count: 1
      expect(page).to have_link 'Voyager Home'
      expect(page).to have_link 'Add Child'
      expect(page).to have_link 'Normal Page'
      expect(page).to have_link 'File Not Found'
      expect(page).to have_link 'Remove'
    end
  end
end