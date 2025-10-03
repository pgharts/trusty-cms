require 'spec_helper'
require 'rack/test'

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
end
