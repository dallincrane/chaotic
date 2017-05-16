# frozen_string_literal: true
require 'spec_helper'

describe 'Objective::Filters::AnyFilter' do
  it 'Allows anything' do
    f = Objective::Filters::AnyFilter.new

    [true, 'hi', 1, [1, 2, 3], { one: 1 }, 1..3, nil].each do |v|
      result = f.feed(v)
      if v.nil?
        assert_nil result.inputs
      else
        assert_equal v, result.inputs
      end
      assert_nil result.errors
    end
  end

  it 'Allows nils by default' do
    f = Objective::Filters::AnyFilter.new

    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'Does not allow nils if set to false' do
    f = Objective::Filters::AnyFilter.new(:a1, nils: false)

    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end
end
