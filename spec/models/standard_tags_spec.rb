require 'spec_helper'

describe 'Standard Tags' do
  # Helper: render a radius string in the context of the given page.
  def render(page, input)
    page.send(:parse, input)
  end

  let(:home) do
    FactoryBot.create(:home, title: 'Home', breadcrumb: 'Home')
  end

  describe '<r:page>' do
    it 'sets the local page to the global page' do
      expect(render(home, '<r:page><r:title /></r:page>')).to eq('Home')
    end
  end

  describe 'attribute tags' do
    it 'renders <r:title />' do
      expect(render(home, '<r:title />')).to eq('Home')
    end

    it 'renders <r:breadcrumb />' do
      expect(render(home, '<r:breadcrumb />')).to eq('Home')
    end

    it 'renders <r:slug />' do
      expect(render(home, '<r:slug />')).to eq('/')
    end
  end
end