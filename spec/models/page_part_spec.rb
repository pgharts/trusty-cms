require 'spec_helper'

describe PagePart do
  describe 'validations' do
    it 'requires a name' do
      part = PagePart.new(content: 'body content')
      expect(part).not_to be_valid
      expect(part.errors[:name]).to be_present
    end

    it 'rejects a name longer than 100 characters' do
      part = PagePart.new(name: 'a' * 101)
      expect(part).not_to be_valid
      expect(part.errors[:name]).to be_present
    end

    it 'rejects a filter_id longer than 25 characters' do
      part = PagePart.new(name: 'body', filter_id: 'a' * 26)
      expect(part).not_to be_valid
      expect(part.errors[:filter_id]).to be_present
    end

    it 'is valid with a name' do
      expect(PagePart.new(name: 'body')).to be_valid
    end
  end

  describe 'ordering' do
    it 'orders by name via the default scope' do
      expect(PagePart.all.to_sql).to match(/ORDER BY name/i)
    end
  end
end
