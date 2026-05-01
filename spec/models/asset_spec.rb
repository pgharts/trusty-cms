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

    it 'returns the direct asset url for pdfs without variant processing' do
      asset = described_class.new(caption: '')
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(true)
      allow(asset).to receive(:content_type).and_return('application/pdf')
      allow(asset).to receive_message_chain(:asset, :url).and_return('https://s3.amazonaws.com/bucket/culturaldistrict/system/assets/20260501/doc-abc123.pdf')
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset).not_to receive(:asset_variant)
      expect(asset.thumbnail('normal')).to eq('https://s3.amazonaws.com/bucket/culturaldistrict/system/assets/20260501/doc-abc123.pdf')
    end

    it 'returns the asset type icon when nothing is attached' do
      asset = described_class.new(caption: '')
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(false)
      allow(asset).to receive(:asset_variant).and_return(nil)
      allow(asset).to receive_message_chain(:asset_type, :icon).with('normal').and_return('/assets/admin/image_icon.png')

      expect(asset.thumbnail('normal')).to eq('/assets/admin/image_icon.png')
    end
  end

  describe '#render_original' do
    it 'returns true for any style when the asset key includes culturaldistrict' do
      asset = described_class.new
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(true)
      allow(asset).to receive_message_chain(:asset, :key).and_return('culturaldistrict/system/assets/20260501/image-abc123.jpg')

      expect(asset.render_original('normal')).to be(true)
      expect(asset.render_original('thumbnail')).to be(true)
      expect(asset.render_original('original')).to be(true)
    end

    it 'returns false when the asset key does not include culturaldistrict' do
      asset = described_class.new
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(true)
      allow(asset).to receive_message_chain(:asset, :key).and_return('tsiv1vf6ythpr2waibv99r01d6zq')

      expect(asset.render_original('normal')).to be(false)
    end

    it 'returns false when no asset is attached' do
      asset = described_class.new
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(false)

      expect(asset.render_original('normal')).to be(false)
    end
  end

  describe '#public_url' do
    let(:original_url) { 'https://s3.amazonaws.com/bucket/culturaldistrict/system/assets/20260501/image-abc123.jpg' }
    let(:variant_url)  { 'https://s3.amazonaws.com/bucket/variants/abc/xyz.jpg' }

    it 'returns the original url for new-style assets regardless of style' do
      asset = described_class.new
      allow(asset).to receive(:render_original).and_return(true)
      allow(asset).to receive_message_chain(:asset, :url).and_return(original_url)
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset.public_url('normal')).to eq(original_url)
      expect(asset.public_url('thumbnail')).to eq(original_url)
    end

    it 'returns the original url when style_name is original' do
      asset = described_class.new
      allow(asset).to receive(:render_original).and_return(false)
      allow(asset).to receive_message_chain(:asset, :url).and_return(original_url)
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset.public_url('original')).to eq(original_url)
    end

    it 'returns a variant url for old-style assets' do
      asset = described_class.new
      allow(asset).to receive(:render_original).and_return(false)
      processed = instance_double(ActiveStorage::Variant, url: variant_url)
      variant   = instance_double(ActiveStorage::Variant, processed: processed)
      allow(asset).to receive(:asset_variant).and_return(variant)
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset.public_url('normal')).to eq(variant_url)
    end

    it 'falls back to the asset url when no variant exists for an old-style asset' do
      asset = described_class.new
      allow(asset).to receive(:render_original).and_return(false)
      allow(asset).to receive(:asset_variant).and_return(nil)
      allow(asset).to receive_message_chain(:asset, :url).and_return('https://s3.amazonaws.com/bucket/tsiv1vf6ythpr2waibv99r01d6zq')
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset.public_url('normal')).to eq('https://s3.amazonaws.com/bucket/tsiv1vf6ythpr2waibv99r01d6zq')
    end
  end
end
