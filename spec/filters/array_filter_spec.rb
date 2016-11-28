# frozen_string_literal: true
require 'spec_helper'
require 'stringio'

describe 'Chaotic::Filters::ArrayFilter' do
  it 'allows arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { any }

    result = f.feed([1])
    assert_equal [1], result.input
    assert_equal nil, result.error
  end

  it 'considers non-arrays to be invalid' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { any }

    ['hi', true, 1, { a: '1' }, Object.new].each do |thing|
      result = f.feed(thing)
      assert_equal :array, result.error
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::ArrayFilter.new(:arr, nils: false) { any }

    result = f.feed(nil)
    assert_equal nil, result.input
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::ArrayFilter.new(:arr, nils: true) { any }

    result = f.feed(nil)
    assert_equal nil, result.error
  end

  it 'lets you use a block to supply an element filter' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { string }

    result = f.feed(['hi', { stuff: 'ok' }])
    assert_nil result.error[0]
    assert_equal :string, result.error[1].symbolic
  end

  it 'lets you array-ize everything' do
    f = Chaotic::Filters::ArrayFilter.new(:arr, arrayize: true) { string }

    result = f.feed('foo')
    assert_equal ['foo'], result.input
    assert_nil result.error
  end

  it 'lets you pass integers in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { integer min: 4 }

    result = f.feed([5, 6, 1, 'bob'])
    assert_equal [5, 6, 1, 'bob'], result.input
    assert_equal [nil, nil, :min, :integer], result.error.symbolic
  end

  it 'lets you pass floats in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:float) { float min: 4.0 }

    result = f.feed([5.0, 6.0, 1.0, 'bob'])
    assert_equal [5.0, 6.0, 1.0, 'bob'], result.input
    assert_equal [nil, nil, :min, :float], result.error.symbolic
  end

  it 'lets you pass ducks in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { duck(methods: :length) }

    result = f.feed(['hi', [1], true])
    assert_equal ['hi', [1], true], result.input
    assert_equal [nil, nil, :duck], result.error.symbolic
  end

  it 'lets you pass dates in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { date(format: '%Y-%m-%d') }

    result = f.feed(['2000-1-1', Date.new(2000, 1, 1), '2000-20-1'])
    assert_equal [Date.new(2000, 1, 1), Date.new(2000, 1, 1), '2000-20-1'], result.input
    assert_equal [nil, nil, :date], result.error.symbolic
  end

  it 'lets you pass files in arrays' do
    sio = StringIO.new('bob')
    f = Chaotic::Filters::ArrayFilter.new(:arr) { file }

    result = f.feed([sio, 'bob'])
    assert_equal [sio, 'bob'], result.input
    assert_equal [nil, :file], result.error.symbolic
  end

  it 'lets you pass booleans in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { boolean }

    result = f.feed([true, false, '1'])
    assert_equal [true, false, true], result.input
    assert_equal nil, result.error
  end

  it 'lets you pass model in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { model :string }

    result = f.feed(['hey'])
    assert_equal ['hey'], result.input
    assert_equal nil, result.error
  end

  it 'lets you pass hashes in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      hash do
        string :foo
        integer :bar
        boolean :baz, discard_nils: true
      end
    end

    result = f.feed([{ foo: 'f', bar: 3, baz: true }, { foo: 'f', bar: 3 }, { foo: 'f' }])
    assert_equal [{ 'foo' => 'f', 'bar' => 3, 'baz' => true }, { 'foo' => 'f', 'bar' => 3 }, { 'foo' => 'f' }], result.input
    assert_equal nil, result.error[0]
    assert_equal nil, result.error[1]
    assert_equal ({ 'bar' => :required }), result.error[2].symbolic
  end

  it 'lets you pass arrays of arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      array do
        string
      end
    end

    result = f.feed([%w(h e), ['l'], [], ['lo']])
    assert_equal [%w(h e), ['l'], [], ['lo']], result.input
    assert_equal nil, result.error
  end

  it 'handles errors for arrays of arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      array do
        string
      end
    end

    result = f.feed([['h', 'e', {}], ['l'], [], ['']])
    assert_equal [[nil, nil, :string], nil, nil, [:empty]], result.error.symbolic
    assert_equal [[nil, nil, '3rd Item must be a string'], nil, nil, ['1st Item cannot be empty']], result.error.message
    assert_equal ['3rd Item must be a string', '1st Item cannot be empty'], result.error.message_list
  end

  it 'strips invalid elements' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      integer discard_invalid: true
    end

    result = f.feed([1, '2', 'three', '4', 5, [6]])
    assert_equal [1, 2, 4, 5], result.input
    assert_equal nil, result.error
  end
end
