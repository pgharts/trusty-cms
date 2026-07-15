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
      AssetType.new :image, icon: 'image', styles: :standard, extensions: %w[jpg jpeg png gif], mime_types: %w[image/png image/x-png image/jpeg image/pjpeg image/jpg image/gif] unless AssetType.known?(:image)
      AssetType.new :video, icon: 'video', mime_types: %w[video/mp4 video/mpeg video/quicktime video/webm] unless AssetType.known?(:video)
      AssetType.new :document, icon: 'document', mime_types: %w[application/msword application/rtf text/plain text/html] unless AssetType.known?(:document)
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

    context 'with stubbed size limits (1 MB asset / 2 MB video)' do
      before do
        allow(TrustyCms.config).to receive(:[]).and_call_original
        allow(TrustyCms.config).to receive(:[]).with('assets.max_asset_size').and_return('1')
        allow(TrustyCms.config).to receive(:[]).with('assets.max_video_size').and_return('2')
      end

      it 'is invalid when a non-video file exceeds the maximum asset size' do
        Tempfile.open(['large', '.png']) do |tempfile|
          tempfile.binmode
          tempfile.write('0' * (1.megabyte + 1))
          tempfile.rewind

          uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
          asset = described_class.new(asset: uploaded)

          expect(asset).not_to be_valid
          expect(asset.errors[:asset]).to include(a_string_matching(/1 MB/))
        end
      end

      it 'is invalid when a video file exceeds the maximum video size' do
        Tempfile.open(['large', '.mp4']) do |tempfile|
          tempfile.binmode
          tempfile.write('0' * (2.megabytes + 1))
          tempfile.rewind

          uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'video/mp4')
          asset = described_class.new(asset: uploaded)

          expect(asset).not_to be_valid
          expect(asset.errors[:asset]).to include(a_string_matching(/2 MB/))
        end
      end

      it 'allows a video file that exceeds the asset size limit but is within the video size limit' do
        Tempfile.open(['video', '.mp4']) do |tempfile|
          tempfile.binmode
          tempfile.write('0' * (1.megabyte + 1.kilobyte))
          tempfile.rewind

          uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'video/mp4')
          asset = described_class.new(asset: uploaded)

          expect(asset).to be_valid
        end
      end

      it 'allows a video file within the maximum video size' do
        Tempfile.open(['video', '.mp4']) do |tempfile|
          tempfile.binmode
          tempfile.write('0' * 1.kilobyte)
          tempfile.rewind

          uploaded = Rack::Test::UploadedFile.new(tempfile.path, 'video/mp4')
          asset = described_class.new(asset: uploaded)

          expect(asset).to be_valid
        end
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
      allow(asset).to receive_message_chain(:asset, :url).and_return('https://s3.amazonaws.com/bucket/myprefix/system/assets/20260501/doc-abc123.pdf')
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset).not_to receive(:asset_variant)
      expect(asset.thumbnail('normal')).to eq('https://s3.amazonaws.com/bucket/myprefix/system/assets/20260501/doc-abc123.pdf')
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
    it 'returns true for any style when the asset key starts with the configured prefix' do
      asset = described_class.new
      allow(TrustyCms::Config).to receive(:[]).with('assets.storage.prefix').and_return('myprefix')
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(true)
      allow(asset).to receive_message_chain(:asset, :key).and_return('myprefix/system/assets/20260501/image-abc123.jpg')

      expect(asset.render_original('normal')).to be(true)
      expect(asset.render_original('thumbnail')).to be(true)
      expect(asset.render_original('original')).to be(true)
    end

    it 'returns true when no prefix is configured but the key contains a path separator' do
      asset = described_class.new
      allow(TrustyCms::Config).to receive(:[]).with('assets.storage.prefix').and_return(nil)
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(true)
      allow(asset).to receive_message_chain(:asset, :key).and_return('system/assets/20260501/image-abc123.jpg')

      expect(asset.render_original('normal')).to be(true)
    end

    it 'returns false when the key does not start with the configured prefix' do
      asset = described_class.new
      allow(TrustyCms::Config).to receive(:[]).with('assets.storage.prefix').and_return('myprefix')
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(true)
      allow(asset).to receive_message_chain(:asset, :key).and_return('randomlegacykey')

      expect(asset.render_original('normal')).to be(false)
    end

    it 'returns false when no asset is attached' do
      asset = described_class.new
      allow(asset).to receive_message_chain(:asset, :attached?).and_return(false)

      expect(asset.render_original('normal')).to be(false)
    end
  end

  describe '#public_url' do
    let(:original_url) { 'https://s3.amazonaws.com/bucket/myprefix/system/assets/20260501/image-abc123.jpg' }
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
      allow(asset).to receive_message_chain(:asset, :url).and_return('https://s3.amazonaws.com/bucket/randomlegacykey')
      allow(asset).to receive(:rewrite_cloud_url) { |url| url }

      expect(asset.public_url('normal')).to eq('https://s3.amazonaws.com/bucket/randomlegacykey')
    end
  end

  # Shared helpers for the blocks below.
  def register_image_and_other_types
    AssetType.new(:image, styles: :standard, extensions: %w[png], mime_types: %w[image/png]) unless AssetType.known?(:image)
    AssetType.new(:other, icon: 'unknown') unless AssetType.known?(:other)
  end

  def png_bytes
    Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==')
  end

  def attach_png(filename: 'pixel.png', **attrs)
    io = StringIO.new(png_bytes)
    io.set_encoding(Encoding::BINARY)
    described_class.new(attrs).tap do |asset|
      asset.asset.attach(io: io, filename: filename, content_type: 'image/png')
      asset.save!
    end
  end

  describe 'unattached accessors' do
    it 'falls back to the stored columns when nothing is attached' do
      asset = described_class.new(asset_file_name: 'legacy.PNG', asset_content_type: 'image/png', asset_file_size: 42)

      expect(asset.filename).to eq('legacy.PNG')
      expect(asset.content_type).to eq('image/png')
      expect(asset.byte_size).to eq(42)
    end

    it 'derives basename and extension from the stored filename' do
      asset = described_class.new(asset_file_name: 'legacy.PNG')

      expect(asset.basename).to eq('legacy')
      expect(asset.original_extension).to eq('png')
      expect(asset.extension('original')).to eq('png')
    end

    it 'returns the original extension for a style with no defined format' do
      asset = described_class.new(asset_file_name: 'legacy.png')

      expect(asset.extension('no_such_style')).to eq('png')
    end
  end

  describe 'geometry' do
    before { register_image_and_other_types }

    it 'reports width, height and aspect from the original dimensions' do
      asset = described_class.new(original_width: 100, original_height: 50)

      expect(asset.width).to eq(100)
      expect(asset.height).to eq(50)
      expect(asset.aspect).to eq(2.0)
      expect(asset.dimensions_known?).to be(true)
    end

    it 'reports a horizontal orientation for a wide asset' do
      asset = described_class.new(original_width: 100, original_height: 50)

      expect(asset.orientation).to eq('horizontal')
      expect(asset.horizontal?).to be(true)
      expect(asset.vertical?).to be(false)
      expect(asset.square?).to be(false)
    end

    it 'reports a vertical orientation for a tall asset' do
      asset = described_class.new(original_width: 50, original_height: 100)

      expect(asset.orientation).to eq('vertical')
      expect(asset.vertical?).to be(true)
    end

    it 'reports a square orientation for an equal-sided asset' do
      asset = described_class.new(original_width: 100, original_height: 100)

      expect(asset.orientation).to eq('square')
      expect(asset.square?).to be(true)
    end

    it 'is not dimensions_known? without stored dimensions' do
      expect(described_class.new.dimensions_known?).to be(false)
    end

    it 'raises a StyleError for a style that is not defined' do
      asset = described_class.new(original_width: 100, original_height: 50)

      expect { asset.geometry('no_such_style') }.to raise_error(TrustyCms::StyleError)
    end
  end

  describe '#active_storage_transformations' do
    subject(:asset) { described_class.new }

    it 'resizes to fill for cropping modifiers' do
      expect(asset.send(:active_storage_transformations, '100x80#')).to eq(resize_to_fill: [100, 80])
    end

    it 'resizes to limit for the shrink modifier' do
      expect(asset.send(:active_storage_transformations, '100x80>')).to eq(resize_to_limit: [100, 80])
    end

    it 'resizes to limit when there is no modifier' do
      expect(asset.send(:active_storage_transformations, '100x80')).to eq(resize_to_limit: [100, 80])
    end

    it 'returns no transformations for a blank geometry' do
      expect(asset.send(:active_storage_transformations, '')).to eq({})
    end
  end

  describe 'scopes' do
    before { register_image_and_other_types }

    let!(:image) { attach_png(caption: 'a picture', title: 'Pixel') }

    describe '.latest' do
      it 'includes recently created assets up to the limit' do
        expect(described_class.latest(5)).to include(image)
      end
    end

    describe '.of_types' do
      it 'includes assets whose blob content type matches the given types' do
        expect(described_class.of_types([:image])).to include(image)
      end

      it 'returns none when the given types have no mime types' do
        expect(described_class.of_types([:no_such_type])).to be_empty
      end
    end

    describe '.matching' do
      it 'matches on filename, title or caption, case-insensitively' do
        expect(described_class.matching('PIXEL')).to include(image)
        expect(described_class.matching('picture')).to include(image)
      end
    end

    describe '.excepting' do
      it 'excludes the given asset ids' do
        expect(described_class.excepting([image.id]).to_sql).to match(/NOT IN/)
        expect(described_class.excepting([image.id])).not_to include(image)
      end

      it 'adds no exclusion when given an empty list' do
        expect(described_class.excepting([])).to eq({})
      end
    end
  end

  describe '#attached_to?' do
    before { register_image_and_other_types }

    it 'is true for a page the asset is attached to, false otherwise' do
      asset = attach_png
      page = FactoryBot.create(:page, title: 'Attached')
      other_page = FactoryBot.create(:page, title: 'Unattached')
      asset.pages << page

      expect(asset.attached_to?(page)).to be(true)
      expect(asset.attached_to?(other_page)).to be(false)
    end
  end

  describe 'class helpers' do
    before { register_image_and_other_types }

    it 'exposes the known asset type names' do
      expect(described_class.known_types).to eq(AssetType.known_types)
    end

    it 'lists ransackable attributes' do
      expect(described_class.ransackable_attributes).to include('title', 'caption', 'uuid')
    end

    it 'exposes the image thumbnail sizes and names' do
      expect(described_class.thumbnail_sizes).to eq(AssetType.find(:image).active_storage_styles)
      expect(described_class.thumbnail_names).to eq(described_class.thumbnail_sizes.keys)
    end

    # NOTE: .thumbnail_options is currently broken for the standard hash-style
    # styles — it does `description << v` where v is the style Hash, which
    # raises TypeError. Documenting the bug here rather than asserting success.
    it 'raises when building thumbnail options from hash-style styles (known bug)' do
      expect { described_class.thumbnail_options }.to raise_error(TypeError)
    end
  end
end
