# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::DuckFilter' do
  it 'allows objects that respond to a single specified method' do
    f = Chaotic::Filters::DuckFilter.new(:quack, methods: [:length])
    result = f.feed('test')
    assert_equal 'test', result.inputs
    assert_equal nil, result.error

    result = f.feed([1, 2])
    assert_equal [1, 2], result.inputs
    assert_equal nil, result.error
  end

  it 'does not allow objects that respond to a single specified method' do
    f = Chaotic::Filters::DuckFilter.new(:quack, methods: [:length])
    result = f.feed(true)
    assert_equal true, result.inputs
    assert_equal :duck, result.error

    result = f.feed(12)
    assert_equal 12, result.inputs
    assert_equal :duck, result.error
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::DuckFilter.new(:quack, nils: false)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::DuckFilter.new(:quack, nils: true)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal nil, result.error
  end

  it 'Allows anything if no methods are specified' do
    f = Chaotic::Filters::DuckFilter.new
    [true, 'hi', 1, [1, 2, 3], { one: 1 }, 1..3].each do |v|
      result = f.feed(v)
      assert_equal v, result.inputs
      assert_equal nil, result.error
    end
  end
end
