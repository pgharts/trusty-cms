require 'spec_helper'

describe FileNotFoundPage do
  subject(:page) { FileNotFoundPage.new }

  it 'is a Page' do
    expect(page).to be_a(Page)
  end

  describe '#cache_timeout' do
    it 'is five minutes' do
      expect(page.cache_timeout).to eq(5.minutes)
    end
  end

  describe '#allowed_children' do
    it 'has none' do
      expect(page.allowed_children).to eq([])
    end
  end

  describe '#virtual?' do
    it 'is true' do
      expect(page.virtual?).to be(true)
    end
  end

  describe '#response_code' do
    it 'is 404' do
      expect(page.response_code).to eq(404)
    end
  end
end
