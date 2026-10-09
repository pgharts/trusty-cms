require 'spec_helper'
require 'ostruct'

describe 'OpenStruct' do

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
