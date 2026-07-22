require 'spec_helper'

# The cache layer of TrustyCms::Config leans on Rails.cache and File.mtime,
# both of which can shift across Rails upgrades. Pin the round-trip. These
# examples are read-only with respect to the config table (which is exempt
# from truncation), so they never persist rows.
describe TrustyCms::Config, 'caching' do
  # Leave the cache in a good state for whatever runs next.
  after { TrustyCms::Config.initialize_cache }

  describe '.ensure_cache_file' do
    it 'creates the cache file' do
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
      key = TrustyCms::Config.to_hash.keys.first
      expect(TrustyCms::Config[key]).to eq(TrustyCms::Config.to_hash[key])
    end

    it 'rebuilds a stale cache before returning a value' do
      TrustyCms::Config.initialize_cache
      key = TrustyCms::Config.to_hash.keys.first
      Rails.cache.write('TrustyCms.cache_mtime', Time.at(0)) # force staleness

      expect(TrustyCms::Config[key]).to eq(TrustyCms::Config.to_hash[key])
      expect(TrustyCms::Config.stale_cache?).to be(false)
    end
  end

  describe '.to_hash' do
    it 'returns a hash keyed by config key' do
      hash = TrustyCms::Config.to_hash
      expect(hash).to be_a(Hash)
      expect(hash.keys).to all(be_a(String))
    end
  end
end
