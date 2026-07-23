require 'spec_helper'

# ActiveRecord::Base monkeypatches. object_id_attr in particular relies on
# .descendants and generated accessors, so pin its behaviour ahead of any
# Rails upgrade. Exercised through PagePart, which uses it in production.
describe 'ActiveRecord extensions' do
  describe '.object_id_attr' do
    it 'instantiates the matching descendant for the stored id' do
      HamlFilter # ensure the descendant is autoloaded
      part = PagePart.new(filter_id: 'Haml')
      expect(part.filter).to be_a(HamlFilter)
    end

    it 'falls back to the base class when no descendant matches' do
      part = PagePart.new(filter_id: nil)
      expect(part.filter.class).to eq(TextFilter)
    end

    it 'memoises the built object until the id changes' do
      part = PagePart.new(filter_id: nil)
      first = part.filter
      expect(part.filter).to equal(first)

      HamlFilter
      part.filter_id = 'Haml'
      expect(part.filter).to be_a(HamlFilter)
    end
  end

  describe '.validates_path' do
    let(:model_class) do
      Class.new(PageField) do
        validates_path :content
        def self.name
          'PathValidatedField'
        end
      end
    end

    it 'is valid when the value resolves to a real page' do
      page = FactoryBot.create(:page, slug: '/', status_id: Status[:published].id)
      allow(Page).to receive(:find_by_path).and_return(page)

      record = model_class.new(name: 'ref', content: '/')
      record.valid?
      expect(record.errors[:content]).to be_empty
    end

    it 'adds an error when the path is not found' do
      allow(Page).to receive(:find_by_path).and_return(nil)

      record = model_class.new(name: 'ref', content: '/missing')
      record.valid?
      expect(record.errors[:content]).to be_present
    end

    it 'adds an error when the path resolves to a FileNotFoundPage' do
      allow(Page).to receive(:find_by_path).and_return(FileNotFoundPage.new)

      record = model_class.new(name: 'ref', content: '/404')
      record.valid?
      expect(record.errors[:content]).to be_present
    end
  end
end
