require 'rails_helper'

describe 'Configuration of a site' do
  describe 'when the config is valid' do
    before(:each) do
      configs = [
        ['admin.title', 'TrustyCms CMS'],
        ['admin.subtitle', 'Publishing for Small Teams'],
        ['defaults.page.parts', 'body, extended'],
        ['defaults.page.status', 'Draft'],
        ['defaults.page.filter', nil],
        ['defaults.page.fields', 'Keywords, Description'],
        ['defaults.snippet.filter', nil],
        ['session_timeout', '1209600'], # 2.weeks.to_s ????
        ['default_locale', 'en'],
      ]
      configs.each do |key, value|
        c = TrustyCms::Config.find_or_initialize_by_key(key)
        c.value = value
        c.save
      end
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
        expect(User.all.count).to equal 1
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
