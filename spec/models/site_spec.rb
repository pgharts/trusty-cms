require 'spec_helper'

describe Site do
  def create_site(attrs = {})
    Site.create!({ name: 'Test', base_domain: 'test.local', domain: 'test\\.local' }.merge(attrs))
  end

  describe '#url' do
    let(:site) { create_site(base_domain: 'example.com') }

    it 'returns the site root for no path' do
      expect(site.url).to eq('http://example.com/')
    end

    it 'joins a path onto the base domain' do
      expect(site.url('/about')).to eq('http://example.com/about')
    end
  end

  describe '.find_for_host' do
    it 'returns the default site for a blank hostname' do
      default = create_site(name: 'Default', base_domain: 'localhost', domain: '')
      expect(Site.find_for_host('')).to eq(default)
    end

    it 'matches a site by its base_domain' do
      # No empty-domain site here: an empty domain pattern matches every host
      # (Regexp.compile('') matches anything) and would shadow specific sites.
      blog = create_site(name: 'Blog', base_domain: 'blog.example.com', domain: 'blog\\.example\\.com')
      expect(Site.find_for_host('blog.example.com')).to eq(blog)
    end

    it 'falls back to the default site for an unknown host' do
      default = create_site(name: 'Default', base_domain: 'localhost', domain: '')
      expect(Site.find_for_host('unknown.example.com')).to eq(default)
    end
  end

  describe '.default' do
    it 'returns the site whose domain is empty' do
      default = create_site(name: 'Default', base_domain: 'localhost', domain: '')
      expect(Site.default).to eq(default)
    end
  end

  describe '.catchall' do
    it 'creates a workable default site when none exists' do
      site = Site.catchall
      expect(site).to be_persisted
      expect(site.name).to eq('default_site')
      expect(site.base_domain).to eq('localhost')
    end
  end

  describe '.several?' do
    before { Site.several = nil }

    it 'is false with a single site' do
      create_site
      expect(Site.several?).to be(false)
    end

    it 'is true with more than one site' do
      create_site(name: 'One', base_domain: 'one.local', domain: 'one\\.local')
      create_site(name: 'Two', base_domain: 'two.local', domain: 'two\\.local')
      expect(Site.several?).to be(true)
    end
  end

  describe 'validations' do
    it 'requires a name and base_domain' do
      site = Site.new
      site.valid?
      expect(site.errors[:name]).to be_present
      expect(site.errors[:base_domain]).to be_present
    end

    it 'requires a unique domain' do
      create_site(domain: 'dup\\.local')
      dup = Site.new(name: 'Dup', base_domain: 'dup2.local', domain: 'dup\\.local')
      expect(dup).not_to be_valid
      expect(dup.errors[:domain]).to be_present
    end
  end

  describe 'homepage creation' do
    it 'builds a homepage automatically after create' do
      site = create_site(base_domain: 'hp.local', domain: 'hp\\.local')
      expect(site.homepage).to be_present
      expect(site.homepage.breadcrumb).to eq('Home')
    end
  end
end
