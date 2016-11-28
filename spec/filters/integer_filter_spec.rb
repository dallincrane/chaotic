# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::IntegerFilter' do
  it 'allows integers' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed(3)

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'allows floats equivalent to an integer' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed(3.0)

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'does not allows floats with partial units' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed(3.1)

    assert_equal 3.1, result.input
    assert_equal :integer, result.error
  end

  it 'allows bigdecimals equivalent to an integer' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed(BigDecimal.new('3.000000'))

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'does not allows floats with partial units' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed(BigDecimal.new('3.111111'))

    assert_equal BigDecimal.new('3.111111'), result.input
    assert_equal :integer, result.error
  end

  it 'allows strings that start with a digit' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed('3')

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'allows negative strings' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed('-3')

    assert result.input.is_a?(Integer)
    assert_equal(-3, result.input)
    assert_equal nil, result.error
  end

  it 'does not allow other strings, nor does it allow random objects or symbols' do
    f = Chaotic::Filters::IntegerFilter.new
    ['zero', 'a1', {}, [], Object.new, :d].each do |thing|
      result = f.feed(thing)
      assert_equal :integer, result.error
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, nils: false)
    result = f.feed(nil)

    assert_equal nil, result.input
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, nils: true)
    result = f.feed(nil)

    assert_equal nil, result.input
    assert_equal nil, result.error
  end

  it 'considers empty strings to be empty' do
    f = Chaotic::Filters::IntegerFilter.new
    result = f.feed('')

    assert_equal :integer, result.error
  end

  it 'considers low numbers invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, min: 10)
    result = f.feed(3)

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_equal :min, result.error
  end

  it 'considers low numbers valid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, min: 10)
    result = f.feed(31)

    assert result.input.is_a?(Integer)
    assert_equal 31, result.input
    assert_equal nil, result.error
  end

  it 'considers high numbers invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, max: 10)
    result = f.feed(31)

    assert result.input.is_a?(Integer)
    assert_equal 31, result.input
    assert_equal :max, result.error
  end

  it 'considers high numbers vaild' do
    f = Chaotic::Filters::IntegerFilter.new(:i, max: 10)
    result = f.feed(3)

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_equal nil, result.error
  end

  it 'considers not matching numbers to be invalid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, in: [3, 4, 5])
    result = f.feed(6)

    assert result.input.is_a?(Integer)
    assert_equal 6, result.input
    assert_equal :in, result.error
  end

  it 'considers matching numbers to be valid' do
    f = Chaotic::Filters::IntegerFilter.new(:i, in: [3, 4, 5])
    result = f.feed(3)

    assert result.input.is_a?(Integer)
    assert_equal 3, result.input
    assert_nil result.error
  end
end
