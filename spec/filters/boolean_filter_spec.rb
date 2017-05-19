# frozen_string_literal: true
require 'spec_helper'

describe 'Objective::Filters::BooleanFilter' do
  it 'allows booleans' do
    f = Objective::Filters::BooleanFilter.new
    result = f.feed(true)
    assert_equal true, result.inputs
    assert_nil result.errors

    result = f.feed(false)
    assert_equal false, result.inputs
    assert_nil result.errors
  end

  it 'considers non-booleans to be invalid' do
    f = Objective::Filters::BooleanFilter.new
    [[true], { a: '1' }, Object.new].each do |thing|
      result = f.feed(thing)
      assert_equal :boolean, result.errors
    end
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::BooleanFilter.new(:bool)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::BooleanFilter.new(:bool, nils: Objective::ALLOW)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'considers certain values to be true' do
    f = Objective::Filters::BooleanFilter.new

    ['true', 'TRUE', 'TrUe', '1', 1].each do |value|
      result = f.feed(value)
      assert_equal true, result.inputs
      assert_nil result.errors
    end
  end

  it 'considers certain values to be true' do
    f = Objective::Filters::BooleanFilter.new

    ['false', 'FALSE', 'FalSe', '0', 0].each do |value|
      result = f.feed(value)
      assert_equal false, result.inputs
      assert_nil result.errors
    end
  end

  it 'considers other string to be invalid' do
    f = Objective::Filters::BooleanFilter.new
    %w(truely 2).each do |str|
      result = f.feed(str)
      assert_equal str, result.inputs
      assert_equal :boolean, result.errors
    end
  end
end
