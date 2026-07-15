require 'spec_helper'

describe RailsPage do
  subject(:page) { RailsPage.new }

  it 'is a Page' do
    expect(page).to be_a(Page)
  end

  describe '#url' do
    it 'returns an explicitly assigned url' do
      page.url = '/custom/path'
      expect(page.url).to eq('/custom/path')
    end
  end

  describe '#build_parts_from_hash!' do
    it 'creates page parts from a content hash' do
      page.build_parts_from_hash!('body' => 'Hello', 'sidebar' => 'World')
      expect(page.part('body').content).to eq('Hello')
      expect(page.part('sidebar').content).to eq('World')
    end

    it 'updates the content of an existing part' do
      page.build_parts_from_hash!('body' => 'first')
      page.build_parts_from_hash!('body' => 'second')
      bodies = page.parts.select { |p| p.name == 'body' }
      expect(bodies.size).to eq(1)
      expect(bodies.first.content).to eq('second')
    end
  end
end
