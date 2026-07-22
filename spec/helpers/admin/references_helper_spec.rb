require 'spec_helper'

describe Admin::ReferencesHelper, type: :helper do
  describe '#class_of_page' do
    it 'defaults to Page when no class_name param is present' do
      allow(helper).to receive(:params).and_return({})
      expect(helper.class_of_page).to eq(Page)
    end

    it 'constantizes the class_name param' do
      allow(helper).to receive(:params).and_return(class_name: 'FileNotFoundPage')
      expect(helper.class_of_page).to eq(FileNotFoundPage)
    end
  end

  describe '#filter' do
    it 'is nil for an unknown filter name' do
      allow(helper).to receive(:params).and_return(filter_name: 'No Such Filter')
      expect(helper.filter).to be_nil
    end

    it 'finds a text filter by its filter_name' do
      HamlFilter # ensure the descendant is autoloaded
      allow(helper).to receive(:params).and_return(filter_name: 'Haml')
      expect(helper.filter).to eq(HamlFilter)
    end
  end

  describe '#filter_reference' do
    it 'explains when there is no filter on the page part' do
      allow(helper).to receive(:params).and_return({})
      expect(helper.filter_reference).to eq('There is no filter on the current page part.')
    end

    it 'explains when a filter has no documentation' do
      HamlFilter
      allow(helper).to receive(:params).and_return(filter_name: 'Haml')
      expect(helper.filter_reference).to eq('There is no documentation on this filter.')
    end
  end

  describe '#_display_name' do
    it 'returns the page class display name for tags' do
      allow(helper).to receive(:params).and_return(type: 'tags')
      expect(helper._display_name).to eq(Page.display_name)
    end

    it 'returns the filter name for filters' do
      HamlFilter
      allow(helper).to receive(:params).and_return(type: 'filters', filter_name: 'Haml')
      expect(helper._display_name).to eq('Haml')
    end
  end
end
