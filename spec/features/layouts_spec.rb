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
      click_link 'New Layout'
      fill_in 'Name', with: 'Petunias'
      fill_in 'Body', with: 'Wisteria'
      click_button 'Create Layout'
    end
  end

  context 'with a layout' do
    before(:each) do
      Layout.create!(name: 'Petunias', body: 'Wisteria')
      visit '/admin/layouts'
    end

    it 'lets you edit the homepage' do
      click_link 'Petunias'

      expect(page).to have_content 'Edit Page'
      expect(page).to have_field 'Page Title', with: 'Voyager Home'
      expect(page).to have_button 'Save Changes'
      expect(page).to have_content 'Last Updated by Kathryn Janeway'
    end

    it 'lets you remove the homepage' do
      click_link 'Remove'

      expect(page).to have_content 'Are you sure you want to permanently remove the following Page?'

      click_button 'Delete Page'

      expect(page).to have_content 'No Pages'
      expect(page).to have_link 'New Homepage'
    end
  end
end
