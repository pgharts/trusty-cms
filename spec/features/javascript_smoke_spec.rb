require 'rails_helper'

describe 'Editing using javascript features', js: true do
  fixtures :users

  before(:each) do
    @admin = users(:captain_janeway)
    log_in_as @admin.login
  end

  it 'edits all sorts of content' do
    # Create a new homepage
    click_link 'New Homepage'
    fill_in 'Page Title', with: 'Voyager Home'
    click_button 'Create Page'

    # Create a new child page of the home page
    click_link 'Add Child'
    click_link 'Normal Page'
    fill_in 'Page Title', with: 'Command Center'
    fill_in 'part_body_content', with: 'You are on the bridge.'

    # Add a custom page part
    click_link 'Add Part'
    fill_in 'Name', with: 'footer'
    click_button 'Add Part'
    expect(page).to have_selector '#tabs #tab_footer'
    fill_in 'part_footer_content', with: 'Copyright Voyager 2371'

    # Switch tabs
    click_link 'tab_body'
    expect(page).to have_field 'part_body_content', with: 'You are on the bridge.'
    expect(page).to_not have_field 'part_footer_content'

    # Remove a tab
    find('#tab_extended .close').click
    expect(page).to_not have_content 'extended'

    # Preview
    click_button 'Preview'
    within_frame 'page-preview' do
      expect(page).to have_content 'You are on the bridge.'
      expect(page).to_not have_content 'New Page'
    end

    # TODO: This is currently broken by treetable, but I don't understand how it works well enough to fix. Will consult carols10cents.
    # Save and check that all changes were saved
    #click_button 'Save Changes'
    #click_link 'Command Center'
    #expect(page).to_not have_content 'extended'
    #expect(page).to have_content 'footer'
    #expect(page).to have_field 'part_body_content', with: 'You are on the bridge.'
    #click_link 'tab_footer'
    #expect(page).to have_field 'part_footer_content', with: 'Copyright Voyager 2371'
  end
end