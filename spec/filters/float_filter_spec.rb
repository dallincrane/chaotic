# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::FloatFilter' do
  it 'allows floats' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed(3.1415926)

    assert result.input.is_a?(Float)
    assert_equal 3.1415926, result.input
    assert_equal nil, result.error
  end

  it 'allows integers' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed(3)

    assert result.input.is_a?(Float)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'allows bigdecimals' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed(BigDecimal.new('3'))

    assert result.input.is_a?(Float)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'allows strings that start with a digit' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed('3')

    assert result.input.is_a?(Float)
    assert_equal 3.0, result.input
    assert_equal nil, result.error
  end

  it 'allows string representation of float' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed('3.14')

    assert result.input.is_a?(Float)
    assert_equal 3.14, result.input
    assert_equal nil, result.error
  end

  it 'allows string representation of float without a number before dot' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed('.14')

    assert result.input.is_a?(Float)
    assert_equal 0.14, result.input
    assert_equal nil, result.error
  end

  it 'allows negative strings' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed('-.14')

    assert result.input.is_a?(Float)
    assert_equal(-0.14, result.input)
    assert_equal nil, result.error
  end

  it 'allows strings with a positive sign' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed('+.14')

    assert result.input.is_a?(Float)
    assert_equal 0.14, result.input
    assert_equal nil, result.error
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Chaotic::Filters::FloatFilter.new
    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      result = f.feed(thing)
      assert_equal :float, result.error
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::FloatFilter.new(:x, nils: false)
    result = f.feed(nil)
    assert_equal nil, result.input
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::FloatFilter.new(:x, nils: true)
    result = f.feed(nil)
    assert_equal nil, result.input
    assert_equal nil, result.error
  end

  it 'considers empty strings invalid' do
    f = Chaotic::Filters::FloatFilter.new
    result = f.feed('')
    assert_equal :float, result.error
  end

  it 'considers low numbers invalid' do
    f = Chaotic::Filters::FloatFilter.new(:x, min: 10)
    result = f.feed(3)

    assert result.input.is_a?(Float)
    assert_equal 3, result.input
    assert_equal :min, result.error
  end

  it 'considers low numbers valid' do
    f = Chaotic::Filters::FloatFilter.new(:x, min: 10)
    result = f.feed(31)

    assert result.input.is_a?(Float)
    assert_equal 31, result.input
    assert_equal nil, result.error
  end

  it 'considers high numbers invalid' do
    f = Chaotic::Filters::FloatFilter.new(:x, max: 10)
    result = f.feed(31)

    assert result.input.is_a?(Float)
    assert_equal 31, result.input
    assert_equal :max, result.error
  end

  it 'considers high numbers vaild' do
    f = Chaotic::Filters::FloatFilter.new(:x, max: 10)
    result = f.feed(3)

    assert result.input.is_a?(Float)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end
end
