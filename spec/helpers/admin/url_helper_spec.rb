require 'spec_helper'

describe Admin::UrlHelper, type: :helper do
  describe '#format_path' do
    it 'returns an empty string for a root or empty path' do
      expect(helper.format_path('')).to eq('')
      expect(helper.format_path('/')).to eq('')
    end

    it 'returns "Root" for a single segment' do
      expect(helper.format_path('foo')).to eq('Root')
    end

    it 'returns "/" for two segments' do
      expect(helper.format_path('foo/bar')).to eq('/')
    end

    it 'returns the middle subpath for deeper paths' do
      expect(helper.format_path('foo/bar/baz')).to eq('/bar')
      expect(helper.format_path('foo/bar/baz/qux')).to eq('/bar/baz')
    end
  end

  describe '#extract_base_url' do
    it 'keeps the scheme and host for a normal url' do
      expect(helper.extract_base_url('http://example.com/some/page')).to eq('http://example.com')
    end

    it 'preserves the port for localhost urls' do
      expect(helper.extract_base_url('http://localhost:3000/some/page')).to eq('http://localhost:3000')
    end
  end

  describe '#default_route?' do
    it 'is true for a plain Page' do
      expect(helper.default_route?(Page.new)).to be(true)
    end

    it 'is false for a page subclass with no configured route' do
      expect(helper.default_route?(FileNotFoundPage.new)).to be_falsey
    end
  end

  describe '#lookup_page_path' do
    it 'returns nil when no custom routes are configured' do
      expect(helper.lookup_page_path(FileNotFoundPage.new)).to be_nil
    end
  end

  describe '#build_url' do
    it 'appends the page path for default-route pages' do
      page = Page.new
      allow(page).to receive(:path).and_return('/about')

      expect(helper.build_url('http://example.com', page)).to eq('http://example.com/about')
    end

    it 'returns nil for a non-default page with no configured path' do
      expect(helper.build_url('http://example.com', FileNotFoundPage.new)).to be_nil
    end
  end

  describe '#generate_page_url' do
    it 'combines the base url and page path' do
      page = Page.new
      allow(page).to receive(:path).and_return('/about')

      expect(helper.generate_page_url('http://example.com/current', page)).to eq('http://example.com/about')
    end
  end
end
