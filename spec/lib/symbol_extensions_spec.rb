require 'spec_helper'
# NOTE: symbol_extensions is not required anywhere in the app itself, so we
# require it explicitly here. Kept as an upgrade tripwire since it depends on
# String#symbolize (see string_extensions).
require 'string_extensions/string_extensions'
require 'symbol_extensions/symbol_extensions'

describe 'Symbol extensions' do
  describe '#symbolize' do
    it 'normalises the symbol via String#symbolize' do
      expect(:'Foo Bar'.symbolize).to eq(:foo_bar)
    end
  end
end
