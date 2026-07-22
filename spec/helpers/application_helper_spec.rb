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
end
