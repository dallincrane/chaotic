# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::AnyFilter' do
  it 'Allows anything' do
    f = Chaotic::Filters::AnyFilter.new

    [true, 'hi', 1, [1, 2, 3], { one: 1 }, 1..3, nil].each do |v|
      result = f.feed(v)
      assert_equal v, result.inputs
      assert_equal nil, result.errors
    end
  end

  it 'Allows nils by default' do
    f = Chaotic::Filters::AnyFilter.new

    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal nil, result.errors
  end

  it 'Does not allow nils if set to false' do
    f = Chaotic::Filters::AnyFilter.new(:a1, nils: false)

    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal :nils, result.errors
  end
end
