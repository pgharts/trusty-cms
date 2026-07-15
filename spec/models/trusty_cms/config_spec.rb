require 'spec_helper'

describe TrustyCms::Config do
  # The custom #value= setter calls save!, and the config table is exempt from
  # DatabaseCleaner truncation, so a saved row would leak across examples and
  # collide on the unique key index. Build unsaved instances and assign the raw
  # attribute with self[:value]= (write_attribute) to bypass the setter.
  def config(key, value = nil)
    TrustyCms::Config.new(key: key).tap do |c|
      c[:value] = value unless value.nil?
    end
  end

  describe '#boolean?' do
    it 'is true when the key ends with a question mark' do
      expect(config('feature.enabled?').boolean?).to be(true)
    end

    it 'is false for an ordinary key with no definition' do
      expect(config('feature.name').boolean?).to be(false)
    end
  end

  describe '#checked?' do
    it 'is true for a boolean setting whose value is "true"' do
      expect(config('x?', 'true').checked?).to be(true)
    end

    it 'is false for a boolean setting whose value is not "true"' do
      expect(config('x?', 'false').checked?).to be(false)
    end
  end

  describe '#value' do
    it 'returns a boolean for a boolean setting' do
      expect(config('x?', 'true').value).to be(true)
    end

    it 'returns the raw string for a non-boolean setting' do
      expect(config('plain', 'hello').value).to eq('hello')
    end
  end

  describe '#selector?' do
    it 'is false when the definition does not restrict the value' do
      expect(config('plain').selector?).to be(false)
    end
  end

  describe '#definition' do
    it 'returns a Definition even when none was declared' do
      expect(config('undeclared').definition).to be_a(TrustyCms::Config::Definition)
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
