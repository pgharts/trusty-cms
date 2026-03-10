require 'spec_helper'
require 'rack/test'
require 'base64'

RSpec.describe Asset, type: :model do
  let(:fixtures_path) { TrustyCms::Engine.root.join('spec', 'fixtures', 'files') }

  def upload_fixture(filename, content_type)
    Rack::Test::UploadedFile.new(fixtures_path.join(filename), content_type)
  end

  describe 'validations' do
    it 'is valid when the content type is approved' do
      asset = described_class.new(asset: upload_fixture('sample.ics', 'text/calendar'))

      expect(asset).to be_valid
    end

    it 'is invalid when the content type is not approved' do
      asset = described_class.new(asset: upload_fixture('sample.txt', 'text/plain'))

      expect(asset).not_to be_valid
      expect(asset.errors[:asset]).to include(a_string_matching(/file format/i))
    end

    it 'is invalid when the file exceeds the maximum size' do
      Tempfile.open(['large', '.png']) do |tempfile|
        tempfile.binmode
        tempfile.write('0' * (10.megabytes + 1))
        tempfile.rewind

        uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
        asset = described_class.new(asset: uploaded)

        expect(asset).not_to be_valid
        expect(asset.errors[:asset]).to include(a_string_matching(/10 MB/))
      end
    end
  end
  describe 'active storage metadata' do
    before do
      AssetType.new :image, :styles => :standard, :extensions => %w[png], :mime_types => %w[image/png] unless AssetType.known?(:image)
    end

    let(:png_data) do
      Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==')
    end

    def png_io
      io = StringIO.new(png_data)
      io.set_encoding(Encoding::BINARY)
      io.rewind
      io
    end

    it 'exposes filename, content type, and size from the attachment' do
      asset = described_class.new(caption: '')
      asset.asset.attach(io: png_io, filename: 'pixel.png', content_type: 'image/png')
      asset.save!

      expect(asset.filename).to eq('pixel.png')
      expect(asset.content_type).to eq('image/png')
      expect(asset.byte_size).to eq(png_data.bytesize)
      expect(asset.original_extension).to eq('png')
    end

    it 'reports styles and extensions from active storage styles' do
      asset = described_class.new(caption: '')
      asset.asset.attach(io: png_io, filename: 'pixel.png', content_type: 'image/png')
      asset.save!

      expect(asset.style?('thumbnail')).to be(true)
      expect(asset.extension('thumbnail').to_s).to eq('png')
    end
  end

  describe 'thumbnails' do
    before do
      AssetType.new :image, :styles => :standard, :extensions => %w[png], :mime_types => %w[image/png] unless AssetType.known?(:image)
    end

    let(:png_data) do
      Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==')
    end

    def png_io
      io = StringIO.new(png_data)
      io.set_encoding(Encoding::BINARY)
      io.rewind
      io
    end

    it 'returns a variant url for known styles' do
      asset = described_class.new(caption: '')
      asset.asset.attach(io: png_io, filename: 'pixel.png', content_type: 'image/png')
      asset.save!

      variant = instance_double(ActiveStorage::Variant, processed: instance_double(ActiveStorage::Variant, url: '/rails/active_storage/variant/test'))
      allow(asset).to receive(:asset_variant).with('thumbnail').and_return(variant)

      expect(asset.thumbnail('thumbnail')).to eq('/rails/active_storage/variant/test')
    end
  end
end
