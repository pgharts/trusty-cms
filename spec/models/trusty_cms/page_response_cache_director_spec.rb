require 'spec_helper'

describe TrustyCms::PageResponseCacheDirector do
  let(:listener) { double('listener') }

  subject(:director) { described_class.new(page, listener) }

  describe '.cache_timeout' do
    around do |example|
      original = described_class.cache_timeout
      example.run
      described_class.cache_timeout = original
    end

    it 'defaults to five minutes' do
      described_class.instance_variable_set(:@cache_timeout, nil)
      expect(described_class.cache_timeout).to eq(5.minutes)
    end

    it 'can be overridden' do
      described_class.cache_timeout = 10.minutes
      expect(described_class.cache_timeout).to eq(10.minutes)
    end
  end

  describe '#set_cache_control' do
    context 'when the request and page are both cacheable' do
      before { allow(listener).to receive(:cacheable_request?).and_return(true) }

      context 'and the page defines its own cache_timeout' do
        let(:page) { double('page', cache?: true, cache_timeout: 2.minutes) }

        it 'sets a public expiry using the page timeout' do
          expect(listener).to receive(:set_expiry).with(2.minutes, public: true, private: false)
          director.set_cache_control
        end
      end

      context 'and the page has no cache_timeout' do
        let(:page) { double('page', cache?: true) }

        it 'sets a public expiry using the class timeout' do
          allow(described_class).to receive(:cache_timeout).and_return(5.minutes)
          expect(listener).to receive(:set_expiry).with(5.minutes, public: true, private: false)
          director.set_cache_control
        end
      end
    end

    context 'when the page is not cacheable' do
      let(:page) { double('page', cache?: false) }
      before { allow(listener).to receive(:cacheable_request?).and_return(true) }

      it 'sends a no-cache, private response and clears the etag' do
        expect(listener).to receive(:set_expiry).with(nil, private: true, 'no-cache' => true)
        expect(listener).to receive(:set_etag).with('')
        director.set_cache_control
      end
    end

    context 'when the request is not cacheable' do
      let(:page) { double('page', cache?: true) }
      before { allow(listener).to receive(:cacheable_request?).and_return(false) }

      it 'sends a non-cacheable response' do
        expect(listener).to receive(:set_expiry).with(nil, private: true, 'no-cache' => true)
        expect(listener).to receive(:set_etag).with('')
        director.set_cache_control
      end
    end
  end
end
