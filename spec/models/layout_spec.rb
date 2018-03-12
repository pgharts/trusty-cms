require 'spec_helper'

describe Layout do

  let(:layout){ FactoryBot.build(:layout) }

  describe 'name' do
    it 'is invalid when blank' do
      layout = FactoryBot.build(:layout, name: '')
      layout.valid?
      expect(layout.errors[:name]).to include("this must not be blank")
    end

    it 'should validate uniqueness of' do
      layout = FactoryBot.build(:layout, name: 'Normal', content: "Content!")
      layout.save!
      other = FactoryBot.build(:layout, name: 'Normal', content: "Content!")
      expect{other.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should validate length of' do
      layout = FactoryBot.build(:layout, name: 'x' * 100)
      expect(layout.errors[:name]).to be_blank
      layout = FactoryBot.build(:layout, name: 'x' * 101)
      expect{layout.save!}.to raise_error(ActiveRecord::RecordInvalid)
      expect(layout.errors[:name]).to include("this must not be longer than 100 characters")
    end
  end
end
