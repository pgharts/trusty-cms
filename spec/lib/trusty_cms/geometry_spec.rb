require 'spec_helper'

RSpec.describe TrustyCms::Geometry do
  describe '.parse' do
    it 'parses basic geometry strings' do
      geom = described_class.parse('100x200')
      expect(geom.width).to eq(100)
      expect(geom.height).to eq(200)
      expect(geom.modifier).to be_nil
    end

    it 'parses geometry modifiers' do
      geom = described_class.parse('640x480@')
      expect(geom.width).to eq(640)
      expect(geom.height).to eq(480)
      expect(geom.modifier).to eq('@')
    end
  end

  describe '#transformed_by' do
    it 'scales to fit preserving aspect ratio' do
      source = described_class.new(400, 200)
      result = source.transformed_by('100x100')
      expect(result.width).to eq(100)
      expect(result.height).to eq(50)
    end
  end
end
