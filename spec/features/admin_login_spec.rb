require 'rails_helper'

describe 'Admin Login' do
  describe 'a valid Admin User' do
    before(:each) do
      @admin_username = 'user'
      @admin_password = 'password'
      User.create name: 'Test User', login: @admin_username, password: @admin_password, password_confirmation: @admin_password, admin: true
    end

    it 'shows a login page' do
      visit '/'
      expect(page).to have_field 'Username or E-mail Address'
      expect(page).to have_field 'Password'
      expect(page).to have_button 'Login'
    end

    context 'after login' do
      before(:each) do
        User.create name: 'Test User', login: 'user', password: 'password', password_confirmation: 'password', admin: true

        visit '/'
        fill_in 'username_or_email', with: 'user'
        fill_in 'password', with: 'password'
        click_on 'Login'
      end

      it 'shows the admin interface' do
        expect(page).to have_content "Logged in as"
      end

      it 'has correct links in header' do
        expect(page).to have_link 'Test User', href: '/admin/preferences/edit'
        expect(page).to have_link 'Logout', href: '/admin/logout'
        expect(page).to have_link 'View Site', href: '/'
      end

      it 'outputs table header as html' do
        expect(page).to have_selector "table#pages th.name"
      end


      it 'can navigate to create new page' do
        visit '/admin/pages/new'
        expect(page).to have_selector "h1", text: "New Page"
      end
    end
  end
end
