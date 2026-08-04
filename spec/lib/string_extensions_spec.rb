require 'spec_helper'
require 'string_extensions/string_extensions'

# Core-class monkeypatch: pin the behaviour so a Ruby/Rails upgrade that shifts
# String#underscore/#humanize or stringex surfaces as a failure here.
describe 'String extensions' do
  describe '#symbolize' do
    it 'collapses non-alphanumerics and underscores into a symbol' do
      expect('Foo Bar!'.symbolize).to eq(:foo_bar)
    end

    it 'strips leading and trailing separators' do
      expect('  Hello--World  '.symbolize).to eq(:hello_world)
    end
  end

  describe '#titlecase' do
    it 'upcases the first letter of each word' do
      expect('hello world'.titlecase).to eq('Hello World')
    end

    it 'leaves already-capitalised words alone' do
      expect('Hello World'.titlecase).to eq('Hello World')
    end
  end

  describe '#to_name' do
    it 'humanises and title-cases a class-style name' do
      expect('FooBar'.to_name).to eq('Foo Bar')
    end

    it 'strips a trailing suffix when given one' do
      expect('FooFilter'.to_name('Filter')).to eq('Foo')
    end
  end

  describe '#parameterize and its aliases' do
    it 'produces a url-style slug' do
      expect('Hello World'.parameterize).to eq('hello-world')
    end

    it 'aliases to_slug, slugify and slugerize to parameterize' do
      expect('Hello World'.to_slug).to eq('hello-world')
      expect('Hello World'.slugify).to eq('hello-world')
      expect('Hello World'.slugerize).to eq('hello-world')
    end

    it 'downcases by default' do
      expect('Hello World'.parameterize).to eq('hello-world')
    end

    it 'preserves case when preserve_case: true' do
      expect('Hello World'.parameterize(preserve_case: true)).to eq('Hello-World')
    end

    it 'uses a custom string separator' do
      expect('Hello World'.parameterize('_')).to eq('hello_world')
    end

    it 'honours the separator and preserve_case together' do
      expect('Hello World'.parameterize('_', preserve_case: true)).to eq('Hello_World')
    end

    # The upgrade added the guard `separator = '-' unless separator.is_a?(String)`
    # so that Rails internals passing a non-String (e.g. a Symbol or nil)
    # fall back to the default rather than blowing up.
    it 'falls back to a dash when the separator is not a String' do
      expect('Hello World'.parameterize(:_)).to eq('hello-world')
      expect('Hello World'.parameterize(nil)).to eq('hello-world')
    end

    # `locale:` is part of the ActiveSupport-compatible signature; accepted and ignored.
    it 'accepts a locale keyword without raising' do
      expect('Hello World'.parameterize(locale: :en)).to eq('hello-world')
    end

    it 'transliterates accented characters before downcasing' do
      expect('Café Déjà Vu'.parameterize).to eq('cafe-deja-vu')
    end

    it 'collapses repeated whitespace into a single separator' do
      expect('Hello   World'.parameterize).to eq('hello-world')
    end

    it 'returns an empty string for an empty string' do
      expect(''.parameterize).to eq('')
    end
  end
end
