# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::IntegerFilter' do
  it 'allows integers' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed(3)

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'allows floats equivalent to an integer' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed(3.0)

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'does not allows floats with non-zero decimal places' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed(3.1)

    assert_equal 3.1, result.inputs
    assert_equal :integer, result.errors
  end

  it 'allows bigdecimals equivalent to an integer' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed(BigDecimal.new('3.000000'))

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'does not allows decimals with non-zero decimal places' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed(BigDecimal.new('3.111111'))

    assert_equal BigDecimal.new('3.111111'), result.inputs
    assert_equal :integer, result.errors
  end

  it 'allows strings that start with a digit' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed('3')

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'allows strings that need to be squished' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed(" \n 3 \r\n ")

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'allows negative strings' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed('-3')

    assert result.inputs.is_a?(Integer)
    assert_equal(-3, result.inputs)
    assert_nil result.errors
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Objective::Filters::IntegerFilter.new
    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      result = f.feed(thing)
      assert_equal :integer, result.errors
    end
  end

  it 'allows alternative number formats' do
    f = Objective::Filters::IntegerFilter.new(:x, delimiter: '.', decimal_mark: ',')
    result = f.feed('123.456,000')

    assert result.inputs.is_a?(Integer)
    assert_equal 123_456, result.inputs
    assert_nil result.errors
  end

  it 'considers periods invalid when provided an alternative number format without a period' do
    f = Objective::Filters::IntegerFilter.new(:x, decimal_mark: '|')
    result = f.feed('3.00')

    assert_equal '3.00', result.inputs
    assert_equal :integer, result.errors
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::IntegerFilter.new(:i)
    result = f.feed(nil)

    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::IntegerFilter.new(:i, nils: Objective::ALLOW)
    result = f.feed(nil)

    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'considers empty strings to be empty' do
    f = Objective::Filters::IntegerFilter.new
    result = f.feed('')

    assert_equal :integer, result.errors
  end

  it 'considers low numbers invalid' do
    f = Objective::Filters::IntegerFilter.new(:i, min: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_equal :min, result.errors
  end

  it 'considers low numbers valid' do
    f = Objective::Filters::IntegerFilter.new(:i, min: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(Integer)
    assert_equal 31, result.inputs
    assert_nil result.errors
  end

  it 'considers high numbers invalid' do
    f = Objective::Filters::IntegerFilter.new(:i, max: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(Integer)
    assert_equal 31, result.inputs
    assert_equal :max, result.errors
  end

  it 'considers high numbers vaild' do
    f = Objective::Filters::IntegerFilter.new(:i, max: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'considers not matching numbers to be invalid' do
    f = Objective::Filters::IntegerFilter.new(:i, in: [3, 4, 5])
    result = f.feed(6)

    assert result.inputs.is_a?(Integer)
    assert_equal 6, result.inputs
    assert_equal :in, result.errors
  end

  it 'considers matching numbers to be valid' do
    f = Objective::Filters::IntegerFilter.new(:i, in: [3, 4, 5])
    result = f.feed(3)

    assert result.inputs.is_a?(Integer)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end
end
