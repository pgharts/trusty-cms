require 'spec_helper'

# The cache layer of TrustyCms::Config leans on Rails.cache and File.mtime,
# both of which can shift across Rails upgrades. Pin the round-trip.
describe TrustyCms::Config, 'caching' do
  # Seed a known key so the read/round-trip assertions can't pass vacuously on
  # an empty config table. The config table is exempt from truncation, so this
  # probe row is removed explicitly after each example.
  let(:probe_key) { 'spec.cache_probe' }
  let(:probe_value) { 'probe-value' }

  before { TrustyCms::Config[probe_key] = probe_value }

  after do
    TrustyCms::Config.where(key: probe_key).delete_all
    TrustyCms::Config.initialize_cache # leave the cache good for whatever runs next
  end

  describe '.ensure_cache_file' do
it 'creates the cache file' do
  File.delete(TrustyCms::Config.cache_file) if File.exist?(TrustyCms::Config.cache_file)
  expect(TrustyCms::Config.cache_file_exists?).to be(false)

  TrustyCms::Config.ensure_cache_file
  expect(TrustyCms::Config.cache_file_exists?).to be(true)
  expect(File.file?(TrustyCms::Config.cache_file)).to be(true)
end
  end

  describe '.initialize_cache' do
    it 'writes the full config hash into Rails.cache' do
      TrustyCms::Config.initialize_cache
      expect(Rails.cache.read('TrustyCms::Config')).to eq(TrustyCms::Config.to_hash)
    end

    it 'leaves the cache non-stale' do
      TrustyCms::Config.initialize_cache
      expect(TrustyCms::Config.stale_cache?).to be(false)
    end
  end

  describe '.stale_cache?' do
    it 'is true when the stored mtime no longer matches the cache file' do
      TrustyCms::Config.initialize_cache
      Rails.cache.write('TrustyCms.cache_mtime', Time.at(0))
      expect(TrustyCms::Config.stale_cache?).to be(true)
    end
  end

  describe '.[]' do
    it 'reads a value through the cache' do
      TrustyCms::Config.initialize_cache
      expect(TrustyCms::Config[probe_key]).to eq(probe_value)
    end

    it 'rebuilds a stale cache before returning a value' do
      TrustyCms::Config.initialize_cache
      Rails.cache.write('TrustyCms.cache_mtime', Time.at(0)) # force staleness

      expect(TrustyCms::Config[probe_key]).to eq(probe_value)
      expect(TrustyCms::Config.stale_cache?).to be(false)
    end
  end

  describe '.to_hash' do
    it 'returns a hash keyed by config key, including seeded entries' do
      hash = TrustyCms::Config.to_hash
      expect(hash).to be_a(Hash)
      expect(hash).to include(probe_key => probe_value)
      expect(hash.keys).to all(be_a(String))
    end
  end
end
