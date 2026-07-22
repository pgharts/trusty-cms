require 'spec_helper'

describe ScopedHelper do
  # ScopedHelper defines #title/#subtitle on its includer (via the included
  # hook) and reads from #current_site, so mix it into a small host class and
  # stub current_site rather than fight ApplicationHelper's own title/subtitle.
  let(:host_class) do
    Class.new do
      include ScopedHelper
      attr_accessor :site
      def current_site
        site
      end
    end
  end

  subject(:helper) { host_class.new }

  def site_double(name:, subtitle:)
    double('site', name: name, subtitle: subtitle)
  end

  describe '#title' do
    it 'uses the current site name when present' do
      helper.site = site_double(name: 'My Site', subtitle: '')
      expect(helper.title).to eq('My Site')
    end

    it 'falls back to the configured admin title when the site name is blank' do
      allow(TrustyCms::Config).to receive(:[]).with('admin.title').and_return('Configured Title')
      helper.site = site_double(name: '', subtitle: '')
      expect(helper.title).to eq('Configured Title')
    end

    it 'falls back to the default when both the site name and config are blank' do
      allow(TrustyCms::Config).to receive(:[]).with('admin.title').and_return(nil)
      helper.site = site_double(name: '', subtitle: '')
      expect(helper.title).to eq('TrustyCMS')
    end
  end

  describe '#subtitle' do
    it 'uses the current site subtitle when present' do
      helper.site = site_double(name: 'My Site', subtitle: 'My Subtitle')
      expect(helper.subtitle).to eq('My Subtitle')
    end

    it 'falls back to the configured admin subtitle when the site subtitle is blank' do
      allow(TrustyCms::Config).to receive(:[]).with('admin.subtitle').and_return('Configured Subtitle')
      helper.site = site_double(name: 'My Site', subtitle: '')
      expect(helper.subtitle).to eq('Configured Subtitle')
    end

    it 'falls back to the default when both the site subtitle and config are blank' do
      allow(TrustyCms::Config).to receive(:[]).with('admin.subtitle').and_return(nil)
      helper.site = site_double(name: 'My Site', subtitle: '')
      expect(helper.subtitle).to eq('publishing for small teams')
    end
  end
end
