# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::BooleanFilter' do
  it 'allows booleans' do
    f = Chaotic::Filters::BooleanFilter.new
    result = f.feed(true)
    assert_equal true, result.inputs
    assert_equal nil, result.error

    result = f.feed(false)
    assert_equal false, result.inputs
    assert_equal nil, result.error
  end

  it 'considers non-booleans to be invalid' do
    f = Chaotic::Filters::BooleanFilter.new
    [[true], { a: '1' }, Object.new].each do |thing|
      result = f.feed(thing)
      assert_equal :boolean, result.error
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::BooleanFilter.new(:bool, nils: false)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::BooleanFilter.new(:bool, nils: true)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal nil, result.error
  end

  it 'considers certain values to be true' do
    f = Chaotic::Filters::BooleanFilter.new

    ['true', 'TRUE', 'TrUe', '1', 1].each do |value|
      result = f.feed(value)
      assert_equal true, result.inputs
      assert_equal nil, result.error
    end
  end

  it 'considers certain values to be true' do
    f = Chaotic::Filters::BooleanFilter.new

    ['false', 'FALSE', 'FalSe', '0', 0].each do |value|
      result = f.feed(value)
      assert_equal false, result.inputs
      assert_equal nil, result.error
    end
  end

  it 'considers other string to be invalid' do
    f = Chaotic::Filters::BooleanFilter.new
    %w(truely 2).each do |str|
      result = f.feed(str)
      assert_equal str, result.inputs
      assert_equal :boolean, result.error
    end
  end
end
