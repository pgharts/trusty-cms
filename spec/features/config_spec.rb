require 'rails_helper'

describe 'Configuration (Settings)' do
  fixtures :users

  before(:each) do
    @admin = users(:captain_janeway)
    log_in_as @admin.login
    click_link 'Settings'
  end

  it 'has personal and site preferences' do
    expect(page).to have_content 'Personal Preferences'
    expect(page).to have_content 'Configuration'
  end

  it 'lets you edit your personal preferences' do
    click_button 'Edit Preferences'
    fill_in 'Name', with: 'Captain Kathryn Janeway'
    click_button 'Save Changes'

    expect(page).to have_content 'Name Captain Kathryn Janeway'
  end

  it 'lets you edit the site preferences' do
    click_button 'Edit Configuration'
    fill_in 'Site Title', with: 'My Special Site'
    click_button 'Save Changes'

    within '#site_title' do
      expect(page).to have_content  'My Special Site'
    end
  end
end
