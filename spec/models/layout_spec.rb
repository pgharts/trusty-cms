require 'spec_helper'

describe Layout do

  let(:layout){ FactoryGirl.build(:layout) }

  describe 'name' do
    it 'is invalid when blank' do
      layout = FactoryGirl.build(:layout, name: '')
      layout.valid?
      expect(layout.errors[:name]).to include("this must not be blank")
    end

    it 'should validate uniqueness of' do
      layout = FactoryGirl.build(:layout, name: 'Normal', content: "Content!")
      layout.save!
      other = FactoryGirl.build(:layout, name: 'Normal', content: "Content!")
      expect{other.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should validate length of' do
      layout = FactoryGirl.build(:layout, name: 'x' * 100)
      expect(layout.errors[:name]).to be_blank
      layout = FactoryGirl.build(:layout, name: 'x' * 101)
      expect{layout.save!}.to raise_error(ActiveRecord::RecordInvalid)
      expect(layout.errors[:name]).to include("this must not be longer than 100 characters")
    end
  end
end
