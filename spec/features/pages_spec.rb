require 'rails_helper'

describe 'Pages' do
  fixtures :users

  before(:each) do
    @admin = users(:captain_janeway)
    log_in_as @admin.login
  end

  context 'without any pages' do
    it 'can create a new homepage' do
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

  context 'with only a homepage' do
    before(:each) do
      Page.create!(title: 'Voyager Home', breadcrumb: 'Home', slug: '/')
      visit '/admin/pages'
    end


    it 'lets you edit the homepage' do
      click_link 'Voyager Home'

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
