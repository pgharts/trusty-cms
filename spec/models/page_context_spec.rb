require 'spec_helper'

describe PageContext do
  let(:page) { FactoryBot.build(:page, title: 'My Page') }
  let(:context) { PageContext.new(page) }

  describe '#initialize' do
    it 'exposes the page it was built for' do
      expect(context.page).to eq(page)
    end

    it 'registers the page as a global' do
      expect(context.globals.page).to eq(page)
    end

    it 'defines a tag for each of the page tags' do
      expect(context.definitions.keys).to include('title')
    end
  end

  describe '#dup' do
    it 'returns an independent PageContext for the same page' do
      copy = context.dup
      expect(copy).to be_a(PageContext)
      expect(copy).not_to equal(context)
      expect(copy.page).to eq(page)
      expect(copy.globals.page).to eq(page)
    end

    it 'copies the definitions rather than sharing them' do
      copy = context.dup
      expect(copy.definitions).not_to equal(context.definitions)
      expect(copy.definitions.keys).to eq(context.definitions.keys)
    end
  end

  describe 'rendering through Page#parse' do
    it 'renders a standard tag' do
      expect(page.send(:parse, '<r:title />')).to eq('My Page')
    end

    context 'when a tag raises and errors are suppressed (production-like)' do
      before { allow_any_instance_of(PageContext).to receive(:raise_errors?).and_return(false) }

      it 'renders the error message inside a div' do
        output = page.send(:parse, '<r:find />')
        expect(output).to match(%r{<div><strong>.*find.*</strong></div>})
      end
    end

    context 'when errors are raised (development/test)' do
      it 'propagates the exception' do
        expect { page.send(:parse, '<r:find />') }.to raise_error(StandardTags::TagError)
      end
    end
  end
end
