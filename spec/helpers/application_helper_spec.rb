require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe 'title and subtitle' do
    it 'falls back to the default title and subtitle' do
      allow(helper).to receive(:trusty_config).and_return({})

      expect(helper.title).to eq('Trusty CMS')
      expect(helper.subtitle).to eq('Publishing for Small Teams')
      expect(helper.default_page_title).to eq('Trusty CMS - Publishing for Small Teams')
    end

    it 'uses the configured title and subtitle when present' do
      allow(helper).to receive(:trusty_config)
        .and_return('admin.title' => 'My Admin', 'admin.subtitle' => 'My Subtitle')

      expect(helper.title).to eq('My Admin')
      expect(helper.subtitle).to eq('My Subtitle')
      expect(helper.default_page_title).to eq('My Admin - My Subtitle')
    end
  end

  describe '#logged_in?' do
    it 'is true when there is a current user' do
      allow(helper).to receive(:current_user).and_return(User.new)
      expect(helper.logged_in?).to be(true)
    end

    it 'is false when there is no current user' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.logged_in?).to be(false)
    end
  end

  describe '#admin? and #designer?' do
    it 'reflects an admin user' do
      user = instance_double(User, admin?: true, designer?: false)
      allow(helper).to receive(:current_user).and_return(user)

      expect(helper.admin?).to be(true)
      expect(helper.designer?).to be(true)
    end

    it 'treats a designer as a designer but not an admin' do
      user = instance_double(User, admin?: false, designer?: true)
      allow(helper).to receive(:current_user).and_return(user)

      expect(helper.admin?).to be(false)
      expect(helper.designer?).to be(true)
    end

    it 'is false for both when there is no current user' do
      allow(helper).to receive(:current_user).and_return(nil)

      expect(helper.admin?).to be_falsey
      expect(helper.designer?).to be_falsey
    end
  end

  describe '#meta_errors? and #meta_label' do
    it 'reports no meta errors and a "More" label' do
      expect(helper.meta_errors?).to be(false)
      expect(helper.meta_label).to eq('More')
    end
  end

  describe '#translate_with_default' do
    it 'returns the given name when there is no translation' do
      expect(helper.translate_with_default('Some Untranslated Name')).to eq('Some Untranslated Name')
    end
  end

  describe '#clean' do
    it 'collapses duplicate slashes and strips a trailing slash from the path' do
      expect(helper.clean('http://example.com/a//b/')).to eq('/a/b')
    end
  end

  describe '#append_image_extension' do
    it 'appends .png when no extension is present' do
      expect(helper.send(:append_image_extension, 'admin/foo')).to eq('admin/foo.png')
    end

    it 'leaves an existing extension untouched' do
      expect(helper.send(:append_image_extension, 'admin/foo.gif')).to eq('admin/foo.gif')
    end
  end

  describe '#available_locales_select' do
    it 'prepends a default option with a blank value' do
      expect(helper.available_locales_select.first.last).to eq('')
    end
  end

  describe '#body_classes' do
    it 'starts as an empty, memoized array' do
      expect(helper.body_classes).to eq([])
      helper.body_classes << 'reversed'
      expect(helper.body_classes).to eq(['reversed'])
    end
  end

  describe '#onsubmit_status' do
    it 'reports a creating status for a new record' do
      expect(helper.onsubmit_status(Snippet.new)).to match(/creat/i)
    end

    it 'reports a saving status for a persisted record' do
      snippet = FactoryBot.create(:snippet, name: 'saved')
      expect(helper.onsubmit_status(snippet)).to match(/saving/i)
    end
  end

  describe '#save_model_button' do
    it 'labels the button Create for a new record' do
      html = helper.save_model_button(Snippet.new)
      expect(html).to include('type="submit"')
      expect(html).to match(/Create/)
    end

    it 'labels the button Save Changes for a persisted record' do
      snippet = FactoryBot.create(:snippet, name: 'persisted')
      expect(helper.save_model_button(snippet)).to match(/Save Changes/)
    end
  end

  describe '#save_model_and_continue_editing_button' do
    it 'renders a continue submit button' do
      html = helper.save_model_and_continue_editing_button(Snippet.new)
      expect(html).to include('name="continue"')
    end
  end

  describe '#image' do
    it 'builds an admin image tag, defaulting the extension to .png' do
      html = helper.image('foo', alt: 'Foo')
      expect(html).to include('admin/foo.png')
      expect(html).to include('alt="Foo"')
    end

    it 'keeps an explicit extension' do
      expect(helper.image('bar.gif')).to include('admin/bar.gif')
    end
  end

  describe '#timestamp' do
    it 'localizes the time with the :timestamp format' do
      time = Time.zone.local(2026, 7, 29, 10, 0, 0)
      expect(helper.timestamp(time)).to eq(I18n.localize(time, format: :timestamp))
    end
  end

  describe '#updated_stamp' do
    it 'returns nil for a new record' do
      expect(helper.updated_stamp(Snippet.new)).to be_nil
    end

    it 'renders an updated line for a persisted record' do
      snippet = FactoryBot.create(:snippet, name: 'stamped')
      html = helper.updated_stamp(snippet)
      expect(html).to include('updated_line')
    end
  end

  describe 'asset overrides' do
    it 'returns no stylesheet overrides when the override files are absent' do
      expect(helper.stylesheet_overrides).to eq([])
    end

    it 'returns no javascript overrides when the override file is absent' do
      expect(helper.javascript_overrides).to eq([])
    end

    it 'includes the stylesheet override when the file exists' do
      allow(File).to receive(:exist?).and_return(true)
      expect(helper.stylesheet_overrides).to eq(['admin/overrides'])
    end

    it 'includes the javascript override when the file exists' do
      allow(File).to receive(:exist?).and_return(true)
      expect(helper.javascript_overrides).to eq(['admin/overrides'])
    end
  end

  describe '#current_url?' do
    it 'matches the current request path' do
      allow(helper.request).to receive(:original_fullpath).and_return('/admin/pages/1/edit')
      expect(helper.current_url?('/admin/pages')).to be_truthy
    end

    it 'does not match an unrelated path' do
      allow(helper.request).to receive(:original_fullpath).and_return('/admin/snippets')
      expect(helper.current_url?('/admin/pages')).to be_falsey
    end
  end

  describe '#current_tab?' do
    it 'is true for a tab containing the current url and memoizes it' do
      item = double('NavItem', relative_url: '/admin/pages')
      tab = [item]
      allow(helper).to receive(:current_url?).with('/admin/pages').and_return(true)

      expect(helper.current_tab?(tab)).to be(true)
      expect(helper.instance_variable_get(:@current_tab)).to eq(tab)
    end
  end

  describe '#pagination_for' do
    it 'returns nil for a collection that is not paginatable' do
      expect(helper.pagination_for(%w[a b c])).to be_nil
    end
  end
end
