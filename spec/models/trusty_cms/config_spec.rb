require 'spec_helper'

describe TrustyCms::Config do
  # The config table is excluded from DatabaseCleaner truncation, so these
  # examples only exercise unsaved instances to avoid leaking rows.

  describe '#boolean?' do
    it 'is true when the key ends with a question mark' do
      expect(TrustyCms::Config.new(key: 'feature.enabled?').boolean?).to be(true)
    end

    it 'is false for an ordinary key with no definition' do
      expect(TrustyCms::Config.new(key: 'feature.name').boolean?).to be(false)
    end
  end

  describe '#checked?' do
    it 'is true for a boolean setting whose value is "true"' do
      expect(TrustyCms::Config.new(key: 'x?', value: 'true').checked?).to be(true)
    end

    it 'is false for a boolean setting whose value is not "true"' do
      expect(TrustyCms::Config.new(key: 'x?', value: 'false').checked?).to be(false)
    end
  end

  describe '#value' do
    it 'returns a boolean for a boolean setting' do
      expect(TrustyCms::Config.new(key: 'x?', value: 'true').value).to be(true)
    end

    it 'returns the raw string for a non-boolean setting' do
      expect(TrustyCms::Config.new(key: 'plain', value: 'hello').value).to eq('hello')
    end
  end

  describe '#selector?' do
    it 'is false when the definition does not restrict the value' do
      expect(TrustyCms::Config.new(key: 'plain').selector?).to be(false)
    end
  end

  describe '#definition' do
    it 'returns a Definition even when none was declared' do
      expect(TrustyCms::Config.new(key: 'undeclared').definition)
        .to be_a(TrustyCms::Config::Definition)
    end
  end

  describe '.site_settings' do
    it 'lists the site-level settings' do
      expect(TrustyCms::Config.site_settings).to eq(%w[site.title site.host local.timezone])
    end
  end

  describe '.default_settings' do
    it 'lists the default settings' do
      expect(TrustyCms::Config.default_settings).to eq(
        %w[defaults.locale defaults.page.filter defaults.page.parts defaults.page.fields defaults.page.status]
      )
    end
  end
end
