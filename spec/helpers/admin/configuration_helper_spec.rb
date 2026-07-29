require 'spec_helper'

# Exercises Admin::ConfigurationHelper, which renders TrustyCms::Config settings
# as read-only rows (show_config) and as edit fields (edit_config), branching on
# whether a setting is boolean, a selector, or free text.
describe Admin::ConfigurationHelper, type: :helper do
  describe '#setting_for' do
    it 'finds or initializes the config entry for a key' do
      setting = helper.setting_for('admin.title')
      expect(setting).to be_a(TrustyCms::Config)
      expect(setting.key).to eq('admin.title')
    end

    it 'memoizes into @trusty_config' do
      helper.setting_for('admin.title')
      expect(helper.instance_variable_get(:@trusty_config)).to have_key('admin.title')
    end
  end

  describe '#definition_for' do
    it 'returns the setting definition' do
      expect(helper.definition_for('admin.title')).to eq(TrustyCms.config.definition_for('admin.title'))
    end
  end

  describe '#show_config' do
    it 'renders a label and value span for a text setting' do
      html = helper.show_config('admin.title')
      expect(html).to include('<label')
      expect(html).to include('id="admin_title"')
    end

    it 'renders yes/no for a boolean setting' do
      html = helper.show_config('assets.create_image_thumbnails?')
      expect(html).to match(/yes|no/i)
    end

    it 'includes a units span for a setting with units' do
      html = helper.show_config('assets.max_asset_size')
      expect(html).to include('class="units"')
    end
  end

  describe '#edit_config' do
    it 'renders a text field for a plain text setting' do
      html = helper.edit_config('admin.title')
      expect(html).to include('type="text"')
      expect(html).to include('name="trusty_config[admin.title]"')
    end

    it 'renders a checkbox (plus hidden field) for a boolean setting' do
      html = helper.edit_config('assets.create_image_thumbnails?')
      expect(html).to include('type="checkbox"')
      expect(html).to include('type="hidden"')
    end

    it 'renders a select for a selector setting' do
      html = helper.edit_config('defaults.page.status')
      expect(html).to include('<select')
    end
  end
end
