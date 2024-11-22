require 'spec_helper'

describe Snippet do

  let(:snippet) { FactoryBot.build(:snippet) }

  describe 'name' do
    it 'is invalid when blank' do
      snippet = FactoryBot.build(:snippet, name: '')
      snippet.valid?
      expect(snippet.errors[:name]).to include("This field is required.")
    end

    it 'should validate uniqueness of' do
      snippet = FactoryBot.build(:snippet, name: 'test_snippet', content: "Content!")
      snippet.save!
      other = FactoryBot.build(:snippet, name: 'test_snippet', content: "Content!")
      expect { other.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should validate length of' do
      snippet = FactoryBot.build(:snippet, name: 'x' * 100)
      expect(snippet.errors[:name]).to be_blank
      snippet = FactoryBot.build(:snippet, name: 'x' * 101)
      expect { snippet.save! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(snippet.errors[:name]).to include("This must not be longer than 100 characters")
    end
  end
end
