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
  end
end
