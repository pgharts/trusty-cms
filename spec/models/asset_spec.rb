require 'spec_helper'
require 'rack/test'
require 'base64'
require 'stringio'

RSpec.describe Asset, type: :model do
  let(:fixtures_path) { TrustyCms::Engine.root.join('spec', 'fixtures', 'files') }

  def upload_fixture(filename, content_type)
    Rack::Test::UploadedFile.new(fixtures_path.join(filename), content_type)
  end

  describe 'validations' do
    before do
      expect(AssetType.known_mimetypes).to include('image/png', 'video/mp4', 'text/plain')
    end

    it 'is valid when the content type is approved' do
      asset = described_class.new(asset: upload_fixture('sample.txt', 'text/plain'))

      expect(asset).to be_valid
    end

    it 'is invalid when the content type is not approved' do
      asset = described_class.new(asset: upload_fixture('sample.txt', 'application/x-unsupported'))

      expect(asset).not_to be_valid
      expect(asset.errors[:asset]).to include(a_string_matching(/file type/i))
    end

    it 'is invalid when a non-video file exceeds the maximum asset size' do
      max_size = TrustyCms.config['assets.max_asset_size'].to_i

      Tempfile.open(['large', '.png']) do |tempfile|
        tempfile.binmode
        tempfile.write('0' * (max_size.megabytes + 1))
        tempfile.rewind

        uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
        asset = described_class.new(asset: uploaded)

        expect(asset).not_to be_valid
        expect(asset.errors[:asset]).to include(a_string_matching(/#{max_size} MB/))
      end
    end

    it 'is invalid when a video file exceeds the maximum video size' do
      max_size = TrustyCms.config['assets.max_video_size'].to_i

      Tempfile.open(['large', '.mp4']) do |tempfile|
        tempfile.binmode
        tempfile.write('0' * (max_size.megabytes + 1))
        tempfile.rewind

        uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'video/mp4')
        asset = described_class.new(asset: uploaded)

        expect(asset).not_to be_valid
        expect(asset.errors[:asset]).to include(a_string_matching(/#{max_size} MB/))
      end
    end

    it 'allows a video file that exceeds the asset size limit but is within the video size limit' do
      asset_limit = TrustyCms.config['assets.max_asset_size'].to_i
      video_limit = TrustyCms.config['assets.max_video_size'].to_i
      size = asset_limit.megabytes + 1.megabyte

      skip 'video limit must be larger than asset limit for this test to be meaningful' unless video_limit > asset_limit

      Tempfile.open(['video', '.mp4']) do |tempfile|
        tempfile.binmode
        tempfile.write('0' * size)
        tempfile.rewind

        uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'video/mp4')
        asset = described_class.new(asset: uploaded)

        expect(asset).to be_valid
      end
    end

    it 'allows a video file within the maximum video size' do
      Tempfile.open(['video', '.mp4']) do |tempfile|
        tempfile.binmode
        tempfile.write('0' * 1.megabyte)
        tempfile.rewind

        uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'video/mp4')
        asset = described_class.new(asset: uploaded)

        expect(asset).to be_valid
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
