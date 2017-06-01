# frozen_string_literal: true

require 'test_helper'
require 'stringio'

describe 'Objective::Filters::ArrayFilter' do
  it 'allows arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) { any }

    result = f.feed([1])
    assert_equal [1], result.inputs
    assert_nil result.errors
  end

  it 'considers non-arrays to be invalid' do
    f = Objective::Filters::ArrayFilter.new(:arr) { any }

    ['hi', true, 1, { a: '1' }, Object.new].each do |thing|
      result = f.feed(thing)
      assert_equal :array, result.errors
    end
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::ArrayFilter.new(:arr) { any }

    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::ArrayFilter.new(:arr, nils: Objective::ALLOW) { any }

    result = f.feed(nil)
    assert_nil result.errors
  end

  it 'lets you use a block to supply an element filter' do
    f = Objective::Filters::ArrayFilter.new(:arr) { string }

    result = f.feed(['hi', { stuff: 'ok' }])
    assert_nil result.errors[0]
    assert_equal :string, result.errors[1].codes
  end

  it 'lets you wrap everything' do
    f = Objective::Filters::ArrayFilter.new(:arr, wrap: true) { any }

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
      assert_nil result.errors
    end

    result = f.feed('foo')
    assert_equal ['foo'], result.inputs
    assert_nil result.errors
  end

  it 'lets you pass integers in arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) { integer min: 4 }

    result = f.feed([5, 6, 1, 'bob'])
    assert_equal [5, 6, 1, 'bob'], result.inputs
    assert_equal [nil, nil, :min, :integer], result.errors.codes
  end

  it 'lets you pass floats in arrays' do
    f = Objective::Filters::ArrayFilter.new(:float) { float min: 4.0 }

    result = f.feed([5.0, 6.0, 1.0, 'bob'])
    assert_equal [5.0, 6.0, 1.0, 'bob'], result.inputs
    assert_equal [nil, nil, :min, :float], result.errors.codes
  end

  it 'lets you pass ducks in arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) { duck(methods: :length) }

    result = f.feed(['hi', [1], true])
    assert_equal ['hi', [1], true], result.inputs
    assert_equal [nil, nil, :duck], result.errors.codes
  end

  it 'lets you pass dates in arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) { date(format: '%Y-%m-%d') }

    result = f.feed(['2000-1-1', Date.new(2000, 1, 1), '2000-20-1'])
    assert_equal [Date.new(2000, 1, 1), Date.new(2000, 1, 1), '2000-20-1'], result.inputs
    assert_equal [nil, nil, :date], result.errors.codes
  end

  it 'lets you pass files in arrays' do
    sio = StringIO.new('bob')
    f = Objective::Filters::ArrayFilter.new(:arr) { file }

    result = f.feed([sio, 'bob'])
    assert_equal [sio, 'bob'], result.inputs
    assert_equal [nil, :file], result.errors.codes
  end

  it 'lets you pass booleans in arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) { boolean }

    result = f.feed([true, false, '1'])
    assert_equal [true, false, true], result.inputs
    assert_nil result.errors
  end

  it 'lets you pass model in arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) { model :string }

    result = f.feed(['hey'])
    assert_equal ['hey'], result.inputs
    assert_nil result.errors
  end

  it 'lets you pass hashes in arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) do
      hash do
        string :foo
        integer :bar
        boolean :baz, nils: Objective::ALLOW
      end
    end

    result = f.feed(
      [
        { foo: 'f', bar: 3, baz: true },
        { foo: 'f', bar: 3 },
        { foo: 'f' }
      ]
    )
    expected_result = [
      { 'foo' => 'f', 'bar' => 3, 'baz' => true },
      { 'foo' => 'f', 'bar' => 3, 'baz' => nil },
      { 'foo' => 'f', 'baz' => nil }
    ]

    assert_equal expected_result, result.inputs
    assert_nil result.errors[0]
    assert_nil result.errors[1]
    assert_equal ({ 'bar' => :nils }), result.errors[2].codes
  end

  it 'lets you pass arrays of arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) do
      array do
        string
      end
    end

    result = f.feed([%w[h e], ['l'], [], ['lo']])
    assert_equal [%w[h e], ['l'], [], ['lo']], result.inputs
    assert_nil result.errors
  end

  it 'handles errors for arrays of arrays' do
    f = Objective::Filters::ArrayFilter.new(:arr) do
      array do
        string
      end
    end

    result = f.feed([['h', 'e', {}], ['l'], [], ['']])
    err_message_empty = '1st Item cannot be empty'
    err_message_string = '3rd Item must be a string'

    assert_equal [[nil, nil, :string], nil, nil, [:empty]], result.errors.codes
    assert_equal [[nil, nil, err_message_string], nil, nil, [err_message_empty]], result.errors.message
    assert_equal [err_message_string, err_message_empty], result.errors.message_list
  end

  it 'can make invalid elements nil' do
    f = Objective::Filters::ArrayFilter.new(:arr) do
      integer invalid: nil
    end

    result = f.feed([1, '2', 'three', '4', 5, [6]])
    assert_nil result.errors
    assert_equal [1, 2, nil, 4, 5, nil], result.inputs
  end

  it 'can allow nil elements' do
    f = Objective::Filters::ArrayFilter.new(:arr) do
      integer nils: Objective::ALLOW
    end

    result = f.feed([nil, 1, '2', nil, nil, '4', 5, nil])
    assert_nil result.errors
    assert_equal [nil, 1, 2, nil, nil, 4, 5, nil], result.inputs
  end

  it 'can allow empty elements' do
    f = Objective::Filters::ArrayFilter.new(:arr) do
      string empty: Objective::ALLOW
    end

    result = f.feed(['', 'foo', '', '', 'bar', ''])
    assert_nil result.errors
    assert_equal ['', 'foo', '', '', 'bar', ''], result.inputs
  end
end
