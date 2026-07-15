require 'spec_helper'

describe PageAttachment do
  describe '#selected?' do
    it 'is false by default' do
      expect(PageAttachment.new.selected?).to be(false)
    end

    it 'is true when selected is set to a truthy value' do
      attachment = PageAttachment.new
      attachment.selected = '1'
      expect(attachment.selected?).to be(true)
    end

    it 'is false when selected is set to nil' do
      attachment = PageAttachment.new
      attachment.selected = nil
      expect(attachment.selected?).to be(false)
    end
  end

  describe '#add_to_list_bottom' do
    it 'keeps an already-assigned position' do
      attachment = PageAttachment.new(position: 5)
      attachment.add_to_list_bottom
      expect(attachment.position).to eq(5)
    end
  end
end
