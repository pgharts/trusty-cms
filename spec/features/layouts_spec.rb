require 'rails_helper'

describe 'Layouts (Design)' do
  fixtures :users

  before(:each) do
    @admin = users(:captain_janeway)
    log_in_as @admin.login
    click_link 'Design'
  end

  context 'without any layouts' do
    it 'says it has no layouts' do
      expect(page).to have_content 'No Layouts'
    end

    it 'lets you add a layout' do
      skip 'Issue #58'
      click_link 'New Layout'
    end
  end
end
