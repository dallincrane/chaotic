# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::InputFilter' do
  it 'Allows anything' do
    f = Chaotic::Filters::InputFilter.new
    [true, 'hi', 1, [1, 2, 3], { one: 1 }, 1..3, nil].each do |v|
      filtered, errors = f.feed(v)
      assert_equal v, filtered
      assert_equal nil, errors
    end
  end
end
