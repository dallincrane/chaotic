# frozen_string_literal: true
require 'spec_helper'
require 'stringio'

describe 'Chaotic::Filters::ArrayFilter' do
  it 'allows arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { any }

    result = f.feed([1])
    assert_equal [1], result.inputs
    assert_equal nil, result.errors
  end

  it 'considers non-arrays to be invalid' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { any }

    ['hi', true, 1, { a: '1' }, Object.new].each do |thing|
      result = f.feed(thing)
      assert_equal :array, result.errors
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::ArrayFilter.new(:arr, nils: false) { any }

    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::ArrayFilter.new(:arr, nils: true) { any }

    result = f.feed(nil)
    assert_equal nil, result.errors
  end

  it 'lets you use a block to supply an element filter' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { string }

    result = f.feed(['hi', { stuff: 'ok' }])
    assert_nil result.errors[0]
    assert_equal :string, result.errors[1].codes
  end

  it 'lets you wrap everything' do
    f = Chaotic::Filters::ArrayFilter.new(:arr, wrap: true) { any }

    [
      [true, [true]],
      ['hi', ['hi']],
      ['', ['']],
      [1, [1]],
      [[1, 2, 3], [1, 2, 3]],
      [{ one: 1 }, [{ one: 1 }]],
      [1..3, [1..3]]
    ].each do |(given, expected)|
      result = f.feed(given)
      assert_equal expected, result.inputs
      assert_equal nil, result.errors
    end

    result = f.feed('foo')
    assert_equal ['foo'], result.inputs
    assert_nil result.errors
  end

  it 'lets you pass integers in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { integer min: 4 }

    result = f.feed([5, 6, 1, 'bob'])
    assert_equal [5, 6, 1, 'bob'], result.inputs
    assert_equal [nil, nil, :min, :integer], result.errors.codes
  end

  it 'lets you pass floats in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:float) { float min: 4.0 }

    result = f.feed([5.0, 6.0, 1.0, 'bob'])
    assert_equal [5.0, 6.0, 1.0, 'bob'], result.inputs
    assert_equal [nil, nil, :min, :float], result.errors.codes
  end

  it 'lets you pass ducks in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { duck(methods: :length) }

    result = f.feed(['hi', [1], true])
    assert_equal ['hi', [1], true], result.inputs
    assert_equal [nil, nil, :duck], result.errors.codes
  end

  it 'lets you pass dates in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { date(format: '%Y-%m-%d') }

    result = f.feed(['2000-1-1', Date.new(2000, 1, 1), '2000-20-1'])
    assert_equal [Date.new(2000, 1, 1), Date.new(2000, 1, 1), '2000-20-1'], result.inputs
    assert_equal [nil, nil, :date], result.errors.codes
  end

  it 'lets you pass files in arrays' do
    sio = StringIO.new('bob')
    f = Chaotic::Filters::ArrayFilter.new(:arr) { file }

    result = f.feed([sio, 'bob'])
    assert_equal [sio, 'bob'], result.inputs
    assert_equal [nil, :file], result.errors.codes
  end

  it 'lets you pass booleans in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { boolean }

    result = f.feed([true, false, '1'])
    assert_equal [true, false, true], result.inputs
    assert_equal nil, result.errors
  end

  it 'lets you pass model in arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) { model :string }

    result = f.feed(['hey'])
    assert_equal ['hey'], result.inputs
    assert_equal nil, result.errors
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
    assert_equal [{ 'foo' => 'f', 'bar' => 3, 'baz' => true }, { 'foo' => 'f', 'bar' => 3 }, { 'foo' => 'f' }], result.inputs
    assert_equal nil, result.errors[0]
    assert_equal nil, result.errors[1]
    assert_equal ({ 'bar' => :required }), result.errors[2].codes
  end

  it 'lets you pass arrays of arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      array do
        string
      end
    end

    result = f.feed([%w(h e), ['l'], [], ['lo']])
    assert_equal [%w(h e), ['l'], [], ['lo']], result.inputs
    assert_equal nil, result.errors
  end

  it 'handles errors for arrays of arrays' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      array do
        string
      end
    end

    result = f.feed([['h', 'e', {}], ['l'], [], ['']])
    assert_equal [[nil, nil, :string], nil, nil, [:empty]], result.errors.codes
    assert_equal [[nil, nil, '3rd Item must be a string'], nil, nil, ['1st Item cannot be empty']], result.errors.message
    assert_equal ['3rd Item must be a string', '1st Item cannot be empty'], result.errors.message_list
  end

  it 'strips invalid elements' do
    f = Chaotic::Filters::ArrayFilter.new(:arr) do
      integer discard_invalid: true
    end

    result = f.feed([1, '2', 'three', '4', 5, [6]])
    assert_equal [1, 2, 4, 5], result.inputs
    assert_equal nil, result.errors
  end
end
