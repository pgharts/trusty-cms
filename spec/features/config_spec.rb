require 'rails_helper'

describe 'Configuration of a site' do
  describe 'valid configuration' do
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

    it 'is a valid site' do
      visit '/'
      expect(page).to have_no_content "Template is missing"
    end
  end
end