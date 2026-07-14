require 'spec_helper'

describe 'StandardTags: <r:meta>' do
  def render(page, input)
    page.send(:parse, input)
  end

  let(:page) { FactoryBot.create(:page, title: 'Home') }

  describe '<r:meta:description>' do
    it 'wraps the description field in a meta element by default' do
      page.fields.create(name: 'description', content: 'A page')
      expect(render(page, '<r:meta:description />'))
        .to eq('<meta name="description" content="A page" />')
    end

    it 'escapes HTML in the description content' do
      page.fields.create(name: 'description', content: 'Tom & Jerry <b>')
      expect(render(page, '<r:meta:description />'))
        .to eq('<meta name="description" content="Tom &amp; Jerry &lt;b&gt;" />')
    end

    it 'returns the raw (escaped) content without a wrapper when tag="false"' do
      page.fields.create(name: 'description', content: 'Tom & Jerry')
      expect(render(page, '<r:meta:description tag="false" />')).to eq('Tom &amp; Jerry')
    end

    it 'renders an empty content element when there is no description field' do
      expect(render(page, '<r:meta:description />'))
        .to eq('<meta name="description" content="" />')
    end
  end

  describe '<r:meta:keywords>' do
    it 'wraps the keywords field in a meta element by default' do
      page.fields.create(name: 'keywords', content: 'ruby, cms')
      expect(render(page, '<r:meta:keywords />'))
        .to eq('<meta name="keywords" content="ruby, cms" />')
    end

    it 'returns the raw (escaped) content without a wrapper when tag="false"' do
      page.fields.create(name: 'keywords', content: 'a & b')
      expect(render(page, '<r:meta:keywords tag="false" />')).to eq('a &amp; b')
    end

    it 'renders an empty content element when there is no keywords field' do
      expect(render(page, '<r:meta:keywords />'))
        .to eq('<meta name="keywords" content="" />')
    end
  end

  describe '<r:meta>' do
    it 'concatenates the description and keywords elements when used as a single tag' do
      page.fields.create(name: 'description', content: 'A page')
      page.fields.create(name: 'keywords', content: 'ruby')
      expect(render(page, '<r:meta />'))
        .to eq('<meta name="description" content="A page" /><meta name="keywords" content="ruby" />')
    end

    it 'expands its contents when used as a double tag' do
      expect(render(page, '<r:meta>inner <r:title /></r:meta>')).to eq('inner Home')
    end
  end
end

describe 'StandardTags: <r:site>' do
  def render(page, input)
    page.send(:parse, input)
  end

  let(:page) { FactoryBot.create(:page, title: 'Home') }

  it 'expands the contents of the site container tag' do
    expect(render(page, '<r:site>content</r:site>')).to eq('content')
  end

  it 'renders the configured site title' do
    TrustyCms::Config['site.title'] = 'My Site'
    expect(render(page, '<r:site:title />')).to eq('My Site')
  end

  it 'renders the configured site host' do
    TrustyCms::Config['site.host'] = 'example.com'
    expect(render(page, '<r:site:host />')).to eq('example.com')
  end
end
