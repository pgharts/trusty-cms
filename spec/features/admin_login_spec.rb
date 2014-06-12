require 'rails_helper'

describe 'Administration Interface Login' do
  fixtures :users

  it 'shows a login page' do
    visit '/'

    expect(page).to have_field 'Username or E-mail Address'
    expect(page).to have_field 'Password'
    expect(page).to have_button 'Login'
  end

  it 'shows an error if the username is wrong' do
    log_in_as 'nonexistent_username'

    expect(find('#error')).to have_content "Invalid username, e-mail address, or password."
  end

  describe 'as an admin user' do
    before(:each) do
      @admin = users(:captain_janeway)
    end

    context 'after login' do
      before(:each) do
        log_in_as @admin.login
      end

      it 'shows the admin interface' do
        expect(page).to have_content "Logged in as"
      end

      it 'has correct links in header' do
        expect(page).to have_link @admin.name, href: '/admin/preferences/edit'
        expect(page).to have_link 'Logout', href: '/admin/logout'
        expect(page).to have_link 'View Site', href: '/'
      end

      it 'has correct links in navigation' do
        within '#navigation' do
          expect(page).to have_link "Content", href: '/admin/pages'
          expect(page).to have_link "Design", href: '/admin/layouts'
          expect(page).to have_link "Settings", href: '/admin/configuration'
        end
      end

      it 'outputs table header as html' do
        expect(page).to have_selector "table#pages th.name"
      end


      it 'can navigate to create new page' do
        visit '/admin/pages/new'
        expect(page).to have_selector "h1", text: "New Page"
      end

      it 'can log out' do
        click_link "Logout"
        expect(page).to have_content "You are now logged out."

        visit '/admin/pages/new'
        expect(page).to have_content "Please Login"
      end
    end

    it 'shows an error if the password is wrong' do
      log_in_as @admin.login, 'passwordwhoops'

      expect(find('#error')).to have_content "Invalid username, e-mail address, or password."
    end
  end

  describe 'as a regular user after login' do
    before(:each) do
      @user = users(:neelix)
      log_in_as @user.login
    end

    it 'can log in to the admin interface' do
      expect(page).to have_content "Logged in as"
    end

    it 'has correct links in navigation' do
      within '#navigation' do
        expect(page).to have_link "Content", href: '/admin/pages'
        expect(page).not_to have_link "Design"
        expect(page).to have_link "Settings", href: '/admin/configuration'
      end
    end
  end
end
