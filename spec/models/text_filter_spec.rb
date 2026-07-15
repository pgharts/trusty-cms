require 'spec_helper'

# Defined at load time so TextFilter.inherited fires and registers a descendant.
class SpecSampleFilter < TextFilter
  def filter(text)
    "[#{text}]"
  end
end

describe TextFilter do
  describe '#filter' do
    it 'returns the text unchanged for the base filter' do
      expect(TextFilter.new.filter('hello')).to eq('hello')
    end
  end

  describe '.filter' do
    it 'delegates to the singleton instance' do
      expect(TextFilter.filter('hello')).to eq('hello')
      expect(SpecSampleFilter.filter('hello')).to eq('[hello]')
    end
  end

  describe '.inherited' do
    it 'derives a filter_name from the subclass name' do
      expect(SpecSampleFilter.filter_name).to eq('Spec Sample')
    end
  end

  describe '.descendants_names' do
    it 'includes the names of registered descendants, sorted' do
      names = TextFilter.descendants_names
      expect(names).to include('Spec Sample')
      expect(names).to eq(names.sort)
    end
  end

  describe '.find_descendant' do
    it 'finds a descendant by its filter_name' do
      expect(TextFilter.find_descendant('Spec Sample')).to eq(SpecSampleFilter)
    end

    it 'returns nil when no descendant matches' do
      expect(TextFilter.find_descendant('No Such Filter')).to be_nil
    end
  end
end
