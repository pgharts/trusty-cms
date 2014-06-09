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
  end
end