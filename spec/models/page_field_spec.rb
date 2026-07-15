require 'spec_helper'

describe PageField do
  describe 'validations' do
    it 'requires a name' do
      field = PageField.new(content: 'value')
      expect(field).not_to be_valid
      expect(field.errors[:name]).to be_present
    end

    it 'is valid with a name' do
      expect(PageField.new(name: 'keywords', content: 'value')).to be_valid
    end
  end
end
