# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::DecimalFilter' do
  it 'allows bigdecimals' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed(BigDecimal.new('0.99999999999999999'))

    assert result.inputs.is_a?(BigDecimal)
    assert_equal '0.99999999999999999', result.inputs.to_s('F')
    assert_equal nil, result.errors
  end

  it 'allows integers' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed(3)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3, result.inputs
    assert_equal nil, result.errors
  end

  it 'allows floats' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed(3.1415926)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3.1415926, result.inputs
    assert_equal nil, result.errors
  end

  it 'allows strings that start with a digit' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed('3')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3.0, result.inputs
    assert_equal nil, result.errors
  end

  it 'allows string representation of float' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed('3.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3.14, result.inputs
    assert_equal nil, result.errors
  end

  it 'allows string representation of float without a number before dot' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed('.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 0.14, result.inputs
    assert_equal nil, result.errors
  end

  it 'allows negative strings' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed('-.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal(-0.14, result.inputs)
    assert_equal nil, result.errors
  end

  it 'allows strings with a positive sign' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed('+.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 0.14, result.inputs
    assert_equal nil, result.errors
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Chaotic::Filters::DecimalFilter.new

    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      result = f.feed(thing)

      assert_equal :decimal, result.errors
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::DecimalFilter.new(:x, nils: false)
    result = f.feed(nil)

    assert_equal nil, result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::DecimalFilter.new(:x, nils: true)
    result = f.feed(nil)

    assert_equal nil, result.inputs
    assert_equal nil, result.errors
  end

  it 'considers empty strings to be invalid' do
    f = Chaotic::Filters::DecimalFilter.new
    result = f.feed('')

    assert_equal :decimal, result.errors
  end

  it 'considers low numbers invalid' do
    f = Chaotic::Filters::DecimalFilter.new(:x, min: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3, result.inputs
    assert_equal :min, result.errors
  end

  it 'considers low numbers valid' do
    f = Chaotic::Filters::DecimalFilter.new(:x, min: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 31, result.inputs
    assert_equal nil, result.errors
  end

  it 'considers high numbers invalid' do
    f = Chaotic::Filters::DecimalFilter.new(:x, max: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 31, result.inputs
    assert_equal :max, result.errors
  end

  it 'considers high numbers vaild' do
    f = Chaotic::Filters::DecimalFilter.new(:x, max: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3, result.inputs
    assert_equal nil, result.errors
  end
end
