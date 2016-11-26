# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::FloatFilter' do
  it 'allows floats' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed(3.1415926)

    assert filtered.is_a?(Float)
    assert_equal 3.1415926, filtered
    assert_equal nil, errors
  end

  it 'allows integers' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed(3)

    assert filtered.is_a?(Float)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'allows bigdecimals' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed(BigDecimal.new('3'))

    assert filtered.is_a?(Float)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

  it 'allows strings that start with a digit' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed('3')

    assert filtered.is_a?(Float)
    assert_equal 3.0, filtered
    assert_equal nil, errors
  end

  it 'allows string representation of float' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed('3.14')

    assert filtered.is_a?(Float)
    assert_equal 3.14, filtered
    assert_equal nil, errors
  end

  it 'allows string representation of float without a number before dot' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed('.14')

    assert filtered.is_a?(Float)
    assert_equal 0.14, filtered
    assert_equal nil, errors
  end

  it 'allows negative strings' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed('-.14')

    assert filtered.is_a?(Float)
    assert_equal(-0.14, filtered)
    assert_equal nil, errors
  end

  it 'allows strings with a positive sign' do
    f = Chaotic::Filters::FloatFilter.new
    filtered, errors = f.feed('+.14')

    assert filtered.is_a?(Float)
    assert_equal 0.14, filtered
    assert_equal nil, errors
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Chaotic::Filters::FloatFilter.new
    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      _filtered, errors = f.feed(thing)
      assert_equal :float, errors
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::FloatFilter.new(:x, nils: false)
    filtered, errors = f.feed(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::FloatFilter.new(:x, nils: true)
    filtered, errors = f.feed(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it 'considers empty strings invalid' do
    f = Chaotic::Filters::FloatFilter.new
    _filtered, errors = f.feed('')
    assert_equal :float, errors
  end

  it 'considers low numbers invalid' do
    f = Chaotic::Filters::FloatFilter.new(:x, min: 10)
    filtered, errors = f.feed(3)

    assert filtered.is_a?(Float)
    assert_equal 3, filtered
    assert_equal :min, errors
  end

  it 'considers low numbers valid' do
    f = Chaotic::Filters::FloatFilter.new(:x, min: 10)
    filtered, errors = f.feed(31)

    assert filtered.is_a?(Float)
    assert_equal 31, filtered
    assert_equal nil, errors
  end

  it 'considers high numbers invalid' do
    f = Chaotic::Filters::FloatFilter.new(:x, max: 10)
    filtered, errors = f.feed(31)

    assert filtered.is_a?(Float)
    assert_equal 31, filtered
    assert_equal :max, errors
  end

  it 'considers high numbers vaild' do
    f = Chaotic::Filters::FloatFilter.new(:x, max: 10)
    filtered, errors = f.feed(3)

    assert filtered.is_a?(Float)
    assert_equal 3, filtered
    assert_equal nil, errors
  end
end
