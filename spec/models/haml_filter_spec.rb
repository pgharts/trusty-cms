require 'spec_helper'

describe HamlFilter do
  subject(:filter) { HamlFilter.new }

  it 'is a TextFilter' do
    expect(filter).to be_a(TextFilter)
  end

  describe '.filter_name' do
    it 'is derived from the class name' do
      expect(HamlFilter.filter_name).to eq('Haml')
    end
  end

  describe '#filter' do
    it 'renders Haml markup to HTML' do
      expect(filter.filter('%p Hello world')).to eq("<p>Hello world</p>\n")
    end

    it 'un-escapes radius tags that Haml would otherwise escape' do
      # Haml escapes the `=` output to &lt;r:title /&gt;; the filter restores it.
      expect(filter.filter('= "<r:title />"')).to eq("<r:title/>\n")
    end

    it 'leaves radius tags in plain text intact' do
      expect(filter.filter("%p\n  <r:title />")).to eq("<p>\n<r:title />\n</p>\n")
    end
  end
end
