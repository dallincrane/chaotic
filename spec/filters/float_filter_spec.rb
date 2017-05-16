# frozen_string_literal: true
require 'spec_helper'

describe 'Objective::Filters::FloatFilter' do
  it 'allows floats' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed(3.1415926)

    assert result.inputs.is_a?(Float)
    assert_equal 3.1415926, result.inputs
    assert_nil result.errors
  end

  it 'allows integers' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed(3)

    assert result.inputs.is_a?(Float)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'allows bigdecimals' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed(BigDecimal.new('3'))

    assert result.inputs.is_a?(Float)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end

  it 'allows strings that start with a digit' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed('3')

    assert result.inputs.is_a?(Float)
    assert_equal 3.0, result.inputs
    assert_nil result.errors
  end

  it 'allows string representation of float' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed('3.14')

    assert result.inputs.is_a?(Float)
    assert_equal 3.14, result.inputs
    assert_nil result.errors
  end

  it 'allows string representation of float without a number before dot' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed('.14')

    assert result.inputs.is_a?(Float)
    assert_equal 0.14, result.inputs
    assert_nil result.errors
  end

  it 'allows negative strings' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed('-.14')

    assert result.inputs.is_a?(Float)
    assert_equal(-0.14, result.inputs)
    assert_nil result.errors
  end

  it 'allows strings with a positive sign' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed('+.14')

    assert result.inputs.is_a?(Float)
    assert_equal 0.14, result.inputs
    assert_nil result.errors
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Objective::Filters::FloatFilter.new
    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      result = f.feed(thing)
      assert_equal :float, result.errors
    end
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::FloatFilter.new(:x, nils: false)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::FloatFilter.new(:x, nils: true)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'considers empty strings invalid' do
    f = Objective::Filters::FloatFilter.new
    result = f.feed('')
    assert_equal :float, result.errors
  end

  it 'considers low numbers invalid' do
    f = Objective::Filters::FloatFilter.new(:x, min: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(Float)
    assert_equal 3, result.inputs
    assert_equal :min, result.errors
  end

  it 'considers low numbers valid' do
    f = Objective::Filters::FloatFilter.new(:x, min: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(Float)
    assert_equal 31, result.inputs
    assert_nil result.errors
  end

  it 'considers high numbers invalid' do
    f = Objective::Filters::FloatFilter.new(:x, max: 10)
    result = f.feed(31)

    assert result.inputs.is_a?(Float)
    assert_equal 31, result.inputs
    assert_equal :max, result.errors
  end

  it 'considers high numbers vaild' do
    f = Objective::Filters::FloatFilter.new(:x, max: 10)
    result = f.feed(3)

    assert result.inputs.is_a?(Float)
    assert_equal 3, result.inputs
    assert_nil result.errors
  end
end
