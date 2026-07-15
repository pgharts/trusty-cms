require 'spec_helper'

describe AssetType do
  # AssetType keeps its registry in class variables, so registrations persist
  # for the whole suite. Register uniquely-named types (guarded by .known?) so
  # these examples don't depend on what other specs have registered.
  before(:all) do
    AssetType.new(:other, icon: 'unknown') unless AssetType.known?(:other)
    unless AssetType.known?(:spec_image)
      AssetType.new(:spec_image,
                    icon: 'image',
                    styles: :standard,
                    extensions: %w[spx],
                    mime_types: %w[image/spectest])
    end
  end

  let(:image) { AssetType.find(:spec_image) }

  describe '#plural' do
    it 'pluralizes the name' do
      expect(image.plural).to eq('spec_images')
    end
  end

  describe '#mime_types' do
    it 'returns the configured mime types' do
      expect(image.mime_types).to eq(%w[image/spectest])
    end
  end

  describe '#condition' do
    it 'builds an IN clause over its mime types' do
      sql, *values = image.condition
      expect(sql).to match(/asset_content_type IN/)
      expect(values).to eq(%w[image/spectest])
    end
  end

  describe '#non_condition' do
    it 'builds a NOT IN clause over its mime types' do
      sql, *values = image.non_condition
      expect(sql).to match(/NOT asset_content_type IN/)
      expect(values).to eq(%w[image/spectest])
    end
  end

  describe '#standard_styles' do
    it 'defines icon, thumbnail and original styles' do
      expect(image.standard_styles.keys).to match_array(%i[icon thumbnail original])
    end
  end

  describe '#normalize_style_rules' do
    it 'wraps a bare geometry string in a hash' do
      expect(image.normalize_style_rules(small: '100x100')).to eq(small: { geometry: '100x100' })
    end

    it 'parses a key=value rule string into a hash' do
      result = image.normalize_style_rules(big: 'geometry=640x640,format=jpg')
      expect(result[:big]).to eq(geometry: '640x640', format: 'jpg')
    end
  end

  describe '.known?' do
    it 'is true for a registered type' do
      expect(AssetType.known?(:spec_image)).to be(true)
    end

    it 'is false for an unregistered type' do
      expect(AssetType.known?(:nonexistent)).to be(false)
    end
  end

  describe '.find and .[]' do
    it 'looks up a type by name' do
      expect(AssetType.find(:spec_image)).to eq(image)
    end

    it 'aliases .[] to .find' do
      expect(AssetType[:spec_image]).to eq(image)
    end

    it 'returns nil for an unknown type' do
      expect(AssetType.find(:nonexistent)).to be_nil
    end
  end

  describe '.from_extension' do
    it 'finds a type by a registered extension' do
      expect(AssetType.from_extension('spx')).to eq(image)
    end
  end

  describe '.from_mimetype' do
    it 'finds a type by a registered mime type' do
      expect(AssetType.from_mimetype('image/spectest')).to eq(image)
    end
  end

  describe '.for' do
    it 'returns the catchall type when there is no attachment' do
      expect(AssetType.for(nil)).to eq(AssetType.catchall)
    end
  end

  describe '.catchall' do
    it 'is the :other type' do
      expect(AssetType.catchall).to eq(AssetType.find(:other))
    end
  end

  describe '.all and .known_types' do
    it 'includes registered types' do
      expect(AssetType.known_types).to include(:spec_image)
      expect(AssetType.all).to include(image)
    end
  end

  describe '.known_mimetypes' do
    it 'includes registered mime types' do
      expect(AssetType.known_mimetypes).to include('image/spectest')
    end
  end

  describe '.mime_types_for' do
    it 'returns the mime types for the named types' do
      expect(AssetType.mime_types_for(:spec_image)).to eq(%w[image/spectest])
    end
  end

  describe '.slice' do
    it 'returns the named types' do
      expect(AssetType.slice(:spec_image)).to eq([image])
    end
  end
end
