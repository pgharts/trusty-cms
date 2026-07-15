require 'spec_helper'

describe SnippetFinder do
  describe '.finder_types' do
    it 'looks in Snippet' do
      expect(SnippetFinder.finder_types).to eq([Snippet])
    end
  end

  describe '.find' do
    it 'finds a snippet by id' do
      snippet = FactoryBot.create(:snippet)
      expect(SnippetFinder.find(snippet.id)).to eq(snippet)
    end
  end

  describe '.find_by_name' do
    it 'finds a snippet by name' do
      snippet = FactoryBot.create(:snippet, name: 'sidebar')
      expect(SnippetFinder.find_by_name('sidebar')).to eq(snippet)
    end

    it 'returns nil when no snippet matches' do
      expect(SnippetFinder.find_by_name('does_not_exist')).to be_nil
    end
  end
end
