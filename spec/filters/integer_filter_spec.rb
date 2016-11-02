# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::IntegerFilter' do
  it 'allows integers' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter(3)

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'allows floats equivalent to an integer' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter(3.0)

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'does not allows floats with partial units' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter(3.1)

    assert_equal 3.1, filtered
    assert_equal :integer, errors
  end

  it 'allows bigdecimals equivalent to an integer' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter(BigDecimal.new('3.000000'))

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'does not allows floats with partial units' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter(BigDecimal.new('3.111111'))

    assert_equal BigDecimal.new('3.111111'), filtered
    assert_equal :integer, errors
  end

  it 'allows strings that start with a digit' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter('3')

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'allows negative strings' do
    f = Chaotic::Filters::IntegerFilter.new
    filtered, errors = f.filter('-3')

    assert filtered.is_a?(Integer)
    assert_equal(-3, filtered)
    assert_equal nil, errors
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Chaotic::Filters::IntegerFilter.new
    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      _filtered, errors = f.filter(thing)
      assert_equal :integer, errors
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, nils: false)
    filtered, errors = f.filter(nil)

    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, nils: true)
    filtered, errors = f.filter(nil)

    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it 'considers empty strings to be empty' do
    f = Chaotic::Filters::IntegerFilter.new
    _filtered, errors = f.filter('')

    assert_equal :integer, errors
  end

  it 'considers empty strings to be nil if empty_is_nil option is used' do
    f = Chaotic::Filters::IntegerFilter.new(:i, empty_is_nil: true)
    _filtered, errors = f.filter('')

    assert_equal :nils, errors
  end

  it 'returns empty strings as nil if empty_is_nil option is used' do
    f = Chaotic::Filters::IntegerFilter.new(:i, empty_is_nil: true, nils: true)
    filtered, errors = f.filter('')

    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it 'considers low numbers invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, min: 10)
    filtered, errors = f.filter(3)

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_equal :min, errors
  end

  it 'considers low numbers valid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, min: 10)
    filtered, errors = f.filter(31)

    assert filtered.is_a?(Integer)
    assert_equal 31, filtered
    assert_equal nil, errors
  end

  it 'considers high numbers invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, max: 10)
    filtered, errors = f.filter(31)

    assert filtered.is_a?(Integer)
    assert_equal 31, filtered
    assert_equal :max, errors
  end

  it 'considers high numbers vaild' do
    f = Chaotic::Filters::IntegerFilter.new(:i, max: 10)
    filtered, errors = f.filter(3)

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'considers not matching numbers to be invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, in: [3, 4, 5])
    filtered, errors = f.filter(6)

    assert filtered.is_a?(Integer)
    assert_equal 6, filtered
    assert_equal :in, errors
  end

  it 'considers matching numbers to be valid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, in: [3, 4, 5])
    filtered, errors = f.filter(3)

    assert filtered.is_a?(Integer)
    assert_equal 3, filtered
    assert_nil errors
  end
end
