require 'spec_helper'
require 'ostruct'

# lib/ostruct.rb reopens OpenStruct (originally patched for a Ruby upgrade) and
# shadows the stdlib version via the load path. This is exactly the kind of
# patch a Ruby/Rails upgrade can break, so pin the behaviour we rely on.
describe 'OpenStruct patch' do
it 'is the project patch, not the stdlib implementation' do
  expect(OpenStruct.instance_method(:initialize).source_location.first)
    .to eq(File.expand_path('../../lib/ostruct.rb', __dir__))
end

  it 'builds accessors from a hash, symbolizing string keys' do
    os = OpenStruct.new('a' => 1, :b => 2)
    expect(os.a).to eq(1)
    expect(os.b).to eq(2)
  end

  it 'returns nil for an unset member' do
    expect(OpenStruct.new.anything).to be_nil
  end

  it 'assigns and reads a member dynamically' do
    os = OpenStruct.new
    os.foo = 'bar'
    expect(os.foo).to eq('bar')
  end

  it 'raises ArgumentError when a setter is given the wrong arity' do
    os = OpenStruct.new
    expect { os.send(:foo=, 1, 2) }.to raise_error(ArgumentError)
  end
end
