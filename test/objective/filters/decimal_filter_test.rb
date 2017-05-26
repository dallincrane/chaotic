# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::DecimalFilter' do
  it 'allows bigdecimals' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed(BigDecimal.new('0.99999999999999999'))

    assert result.inputs.is_a?(BigDecimal)
    assert_equal '0.99999999999999999', result.inputs.to_s('F')
    assert_nil result.errors
  end

  it 'allows integers' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed(3)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'allows floats' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed(3.1415926)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3.1415926, result.inputs
    assert_nil result.errors
  end

  it 'allows strings that start with a digit' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('3')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3.0, result.inputs
    assert_nil result.errors
  end

  it 'allows string representation of float' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('3.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3.14, result.inputs
    assert_nil result.errors
  end

  it 'allows string representation of float without a number before dot' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 0.14, result.inputs
    assert_nil result.errors
  end

  it 'allows negative strings' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('-.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal(-0.14, result.inputs)
    assert_nil result.errors
  end

  it 'allows strings with a positive sign' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('+.14')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 0.14, result.inputs
    assert_nil result.errors
  end

  it 'allows spaces in strings as a delimiter' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('123 456.789')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 123_456.789, result.inputs
    assert_nil result.errors
  end

  it 'allows commas in strings as a delimiter' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('123,456.789')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 123_456.789, result.inputs
    assert_nil result.errors
  end

  it 'does not allow random objects, symbols, or strings with non-numeric characters' do
    f = Objective::Filters::DecimalFilter.new

    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      result = f.feed(thing)

      assert_equal :decimal, result.errors
    end
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::DecimalFilter.new(:x)
    result = f.feed(nil)

    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::DecimalFilter.new(:x, nils: Objective::ALLOW)
    result = f.feed(nil)

    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'considers empty strings to be invalid' do
    f = Objective::Filters::DecimalFilter.new
    result = f.feed('')

    assert_equal :decimal, result.errors
  end

  it 'allows alternative number formats' do
    f = Objective::Filters::DecimalFilter.new(:x, delimiter: '.', decimal_mark: ',')
    result = f.feed('123.456,789')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 123_456.789, result.inputs
    assert_nil result.errors
  end

  it 'considers periods invalid when provided an alternative number format without a period' do
    f = Objective::Filters::DecimalFilter.new(:x, decimal_mark: '|')
    result = f.feed('3.14')

    assert_equal '3.14', result.inputs
    assert_equal :decimal, result.errors
  end

  it 'considers numbers with less decimal points than the scale value to be valid' do
    f = Objective::Filters::DecimalFilter.new(:x, scale: 2)
    result = f.feed('1.2')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 1.2, result.inputs
    assert_nil result.errors
  end

  it 'considers numbers with the same decimal points as the scale value to be valid' do
    f = Objective::Filters::DecimalFilter.new(:x, scale: 2)
    result = f.feed('1.23')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 1.23, result.inputs
    assert_nil result.errors
  end

  it 'considers numbers with more decimal points than scale value to be invalid' do
    f = Objective::Filters::DecimalFilter.new(:x, scale: 2)
    result = f.feed('1.234')

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 1.234, result.inputs
    assert_equal :scale, result.errors
  end

  it 'considers low numbers invalid' do
    f = Objective::Filters::DecimalFilter.new(:x, min: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3, result.inputs
    assert_equal :min, result.errors
  end

  it 'considers low numbers valid' do
    f = Objective::Filters::DecimalFilter.new(:x, min: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 31, result.inputs
    assert_nil result.errors
  end

  it 'considers high numbers invalid' do
    f = Objective::Filters::DecimalFilter.new(:x, max: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 31, result.inputs
    assert_equal :max, result.errors
  end

  it 'considers high numbers vaild' do
    f = Objective::Filters::DecimalFilter.new(:x, max: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(BigDecimal)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end
end
