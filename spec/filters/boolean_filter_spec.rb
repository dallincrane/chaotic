# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::BooleanFilter' do
  it 'allows booleans' do
    f = Chaotic::Filters::BooleanFilter.new
    filtered, errors = f.feed(true)
    assert_equal true, filtered
    assert_equal nil, errors

    filtered, errors = f.feed(false)
    assert_equal false, filtered
    assert_equal nil, errors
  end

  it 'considers non-booleans to be invalid' do
    f = Chaotic::Filters::BooleanFilter.new
    [[true], { a: '1' }, Object.new].each do |thing|
      _filtered, errors = f.feed(thing)
      assert_equal :boolean, errors
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::BooleanFilter.new(:bool, nils: false)
    filtered, errors = f.feed(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::BooleanFilter.new(:bool, nils: true)
    filtered, errors = f.feed(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it 'considers certain strings to be valid booleans' do
    f = Chaotic::Filters::BooleanFilter.new
    [['true', true], ['TRUE', true], ['TrUe', true], ['1', true], ['false', false], ['FALSE', false], ['FalSe', false], ['0', false], [0, false], [1, true]].each do |(str, v)|
      filtered, errors = f.feed(str)
      assert_equal v, filtered
      assert_equal nil, errors
    end
  end

  it 'considers empty strings to be empty' do
    f = Chaotic::Filters::BooleanFilter.new
    _filtered, errors = f.feed('')
    assert_equal :empty, errors
  end

  it 'considers other string to be invalid' do
    f = Chaotic::Filters::BooleanFilter.new
    ['truely', '2'].each do |str|
      filtered, errors = f.feed(str)
      assert_equal str, filtered
      assert_equal :boolean, errors
    end
  end
end
