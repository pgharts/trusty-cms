require 'spec_helper'

describe Status do
  describe '#initialize' do
    it 'assigns id and name from options' do
      status = Status.new(id: 1, name: 'Draft')
      expect(status.id).to eq(1)
      expect(status.name).to eq('Draft')
    end

    it 'accepts string keys' do
      status = Status.new('id' => 1, 'name' => 'Draft')
      expect(status.id).to eq(1)
      expect(status.name).to eq('Draft')
    end
  end

  describe '#symbol' do
    it 'returns the downcased name as a symbol' do
      expect(Status.new(name: 'Published').symbol).to eq(:published)
    end
  end

  describe '.[]' do
    it 'finds a status by its symbol' do
      expect(Status[:published].name).to eq('Published')
    end

    it 'is case-insensitive' do
      expect(Status['Published']).to eq(Status[:published])
    end

    it 'returns nil for an unknown symbol' do
      expect(Status[:nonexistent]).to be_nil
    end
  end

  describe '.find' do
    it 'finds a status by its id' do
      expect(Status.find(100).name).to eq('Published')
    end

    it 'matches ids regardless of type' do
      expect(Status.find('100')).to eq(Status.find(100))
    end

    it 'returns nil for an unknown id' do
      expect(Status.find(999)).to be_nil
    end
  end

  describe '.selectable' do
    it 'returns all defined statuses' do
      expect(Status.selectable.map(&:name)).to eq(%w[Draft Reviewed Scheduled Published Hidden])
    end
  end

  describe '.selectable_values' do
    it 'returns the names of all selectable statuses' do
      expect(Status.selectable_values).to eq(%w[Draft Reviewed Scheduled Published Hidden])
    end
  end
end
