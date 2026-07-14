require 'spec_helper'

describe 'StandardTags: <r:content>' do
  # Render radius markup in the context of the given page.
  def render(page, input)
    page.send(:parse, input)
  end

  let(:page) { FactoryBot.create(:page, title: 'Home') }

  # 1. Happy path: renders the default `body` part.
  it 'renders the body part by default' do
    page.parts.create(name: 'body', content: 'Hello world')
    expect(render(page, '<r:content />')).to eq('Hello world')
  end

  # 2. Named part via the `part` attribute.
  it 'renders a named part when given the part attribute' do
    page.parts.create(name: 'sidebar', content: 'Sidebar text')
    expect(render(page, '<r:content part="sidebar" />')).to eq('Sidebar text')
  end

  # 3. Missing part -> `part` is nil -> renders empty (line 500 leaves result nil).
  it 'renders nothing when the requested part does not exist' do
    expect(render(page, '<r:content part="nonexistent" />')).to eq('')
  end

  # 7. Nested radius tags inside the part are parsed by render_snippet.
  it 'parses radius tags contained in the part' do
    page.parts.create(name: 'body', content: 'Title is <r:title />')
    expect(render(page, '<r:content />')).to eq('Title is Home')
  end

  describe 'inherit' do
    let(:parent) { FactoryBot.create(:page, title: 'Parent') }
    let(:child)  { FactoryBot.create(:page, title: 'Child', parent: parent) }

    before { parent.parts.create(name: 'body', content: 'Parent body') }

    # 4. inherit="true" walks up to the parent's part.
    it 'renders an inherited part from the parent when inherit is true' do
      expect(render(child, '<r:content inherit="true" />')).to eq('Parent body')
    end

    # 5. Default (inherit=false) does not walk up.
    it 'renders nothing when the part is missing and inherit is false' do
      expect(render(child, '<r:content />')).to eq('')
    end
  end

  # 6. Recursion guard raises TagError (errors are raised in the test env).
  it 'raises a TagError on recursive rendering of the same part' do
    page.parts.create(name: 'body', content: 'loop <r:content />')
    expect { render(page, '<r:content />') }
      .to raise_error(StandardTags::TagError, /Recursion error/)
  end

  # 8. A non-boolean value for a boolean attribute raises TagError.
  it 'raises a TagError when inherit is not a boolean' do
    page.parts.create(name: 'body', content: 'Hello')
    expect { render(page, '<r:content inherit="maybe" />') }
      .to raise_error(StandardTags::TagError)
  end
end

describe 'StandardTags: <r:if_content>' do
  def render(page, input)
    page.send(:parse, input)
  end

  let(:page) { FactoryBot.create(:page, title: 'Home') }

  it 'expands when the default body part exists' do
    page.parts.create(name: 'body', content: 'x')
    expect(render(page, '<r:if_content>shown</r:if_content>')).to eq('shown')
  end

  it 'does not expand when the part is missing' do
    expect(render(page, '<r:if_content>shown</r:if_content>')).to eq('')
  end

  describe 'multiple parts' do
    before { page.parts.create(name: 'body', content: 'x') }

    it 'find="all" (default) does not expand when one listed part is missing' do
      expect(render(page, '<r:if_content part="body, sidebar">shown</r:if_content>')).to eq('')
    end

    it 'find="all" expands when every listed part exists' do
      page.parts.create(name: 'sidebar', content: 'y')
      expect(render(page, '<r:if_content part="body, sidebar">shown</r:if_content>')).to eq('shown')
    end

    it 'find="any" expands when at least one listed part exists' do
      expect(render(page, '<r:if_content part="body, sidebar" find="any">shown</r:if_content>')).to eq('shown')
    end
  end

  describe 'inherit' do
    let(:parent) { FactoryBot.create(:page, title: 'Parent') }
    let(:child)  { FactoryBot.create(:page, title: 'Child', parent: parent) }

    before { parent.parts.create(name: 'body', content: 'Parent body') }

    it 'expands when an ancestor has the part and inherit is true' do
      expect(render(child, '<r:if_content inherit="true">shown</r:if_content>')).to eq('shown')
    end

    it 'does not expand for an inherited part when inherit is false' do
      expect(render(child, '<r:if_content>shown</r:if_content>')).to eq('')
    end
  end

  it 'raises a TagError for an invalid find value' do
    page.parts.create(name: 'body', content: 'x')
    expect { render(page, '<r:if_content find="bogus">shown</r:if_content>') }
      .to raise_error(StandardTags::TagError)
  end
end

describe 'StandardTags: <r:unless_content>' do
  def render(page, input)
    page.send(:parse, input)
  end

  let(:page) { FactoryBot.create(:page, title: 'Home') }

  it 'expands when the default body part is missing' do
    expect(render(page, '<r:unless_content>shown</r:unless_content>')).to eq('shown')
  end

  it 'does not expand when the part exists' do
    page.parts.create(name: 'body', content: 'x')
    expect(render(page, '<r:unless_content>shown</r:unless_content>')).to eq('')
  end

  describe 'multiple parts' do
    before { page.parts.create(name: 'body', content: 'x') }

    it 'find="all" (default) expands when at least one listed part is missing' do
      expect(render(page, '<r:unless_content part="body, sidebar">shown</r:unless_content>')).to eq('shown')
    end

    it 'find="any" does not expand when any listed part is found' do
      expect(render(page, '<r:unless_content part="body, sidebar" find="any">shown</r:unless_content>')).to eq('')
    end

    it 'find="any" expands when none of the listed parts exist' do
      expect(render(page, '<r:unless_content part="header, sidebar" find="any">shown</r:unless_content>')).to eq('shown')
    end
  end

  describe 'inherit' do
    let(:parent) { FactoryBot.create(:page, title: 'Parent') }
    let(:child)  { FactoryBot.create(:page, title: 'Child', parent: parent) }

    before { parent.parts.create(name: 'body', content: 'Parent body') }

    it 'does not expand when an ancestor has the part and inherit is true' do
      expect(render(child, '<r:unless_content inherit="true">shown</r:unless_content>')).to eq('')
    end
  end

  it 'raises a TagError for an invalid find value' do
    expect { render(page, '<r:unless_content find="bogus">shown</r:unless_content>') }
      .to raise_error(StandardTags::TagError)
  end
end
