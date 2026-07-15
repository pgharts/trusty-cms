require 'spec_helper'

describe SnippetTags do
  # In production the snippets extension mixes SnippetTags into Page. Mirror
  # that here so the snippet/yield tags are available through Page#parse.
  before(:all) { Page.include(SnippetTags) unless Page.include?(SnippetTags) }

  let(:page) { Page.new(title: 'Host') }

  def render(input)
    page.send(:parse, input)
  end

  describe '<r:snippet>' do
    it 'renders the named snippet within the page' do
      FactoryBot.create(:snippet, name: 'hello', content: 'Hello Snippet')
      expect(render('<r:snippet name="hello" />')).to eq('Hello Snippet')
    end

    it 'substitutes the double-tag body for <r:yield/>' do
      FactoryBot.create(:snippet, name: 'wrap', content: 'before <r:yield/> after')
      expect(render('<r:snippet name="wrap">MIDDLE</r:snippet>')).to eq('before MIDDLE after')
    end

    it 'raises when the name attribute is missing' do
      expect { render('<r:snippet />') }.to raise_error(StandardTags::TagError, /name.*attribute/)
    end

    it 'raises when the snippet does not exist' do
      expect { render('<r:snippet name="nope" />') }
        .to raise_error(SnippetTags::TagError, /snippet 'nope' not found/)
    end

    it 'caches a snippet looked up more than once in a render' do
      FactoryBot.create(:snippet, name: 'twice', content: 'X')
      expect(SnippetFinder).to receive(:find_by_name).once.and_call_original
      render('<r:snippet name="twice" /><r:snippet name="twice" />')
    end
  end

  describe '<r:yield>' do
    it 'outputs nothing outside of a double-tag snippet' do
      expect(render('<r:yield/>')).to eq('')
    end
  end
end
