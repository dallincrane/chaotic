# frozen_string_literal: true
require 'spec_helper'

describe 'Objective::Filters::DateFilter' do
  it 'takes a date object' do
    date = Date.new
    f = Objective::Filters::DateFilter.new
    result = f.feed(date)
    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'takes a DateTime object' do
    date = DateTime.new
    f = Objective::Filters::DateFilter.new
    result = f.feed(date)
    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'takes a Time object and converts it to a date' do
    time = Time.now
    f = Objective::Filters::DateFilter.new
    result = f.feed(time)
    if time.respond_to?(:to_date)
      assert_equal time.to_date, result.inputs
      assert_nil result.errors
    else
      assert_equal :date, result.errors
    end
  end

  it 'checks if the given date is after a certain date' do
    date = Date.new(2005, 1, 1)
    after_date = Date.new(2000, 1, 1)
    f = Objective::Filters::DateFilter.new(:d1, after: after_date)
    result = f.feed(date)

    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'gives errors when the given date is before the after date' do
    date = Date.new(1995, 1, 1)
    after_date = Date.new(2000, 1, 1)
    f = Objective::Filters::DateFilter.new(:d1, after: after_date)
    result = f.feed(date)

    assert_equal date, result.inputs
    assert_equal :after, result.errors
  end

  it 'checks if the given date is before a certain date' do
    date = Date.new(1995, 1, 1)
    after_date = Date.new(2000, 1, 1)
    f = Objective::Filters::DateFilter.new(:d1, before: after_date)
    result = f.feed(date)

    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'gives errors when the given date is after the before date' do
    date = Date.new(2005, 1, 1)
    before_date = Date.new(2000, 1, 1)
    f = Objective::Filters::DateFilter.new(:d1, before: before_date)
    result = f.feed(date)

    assert_equal date, result.inputs
    assert_equal :before, result.errors
  end

  it 'checks if the given date is in the given range' do
    date = Date.new(2005, 1, 1)
    after_date = Date.new(2000, 1, 1)
    before_date = Date.new(2010, 1, 1)
    f = Objective::Filters::DateFilter.new(:d1, after: after_date, before: before_date)
    result = f.feed(date)

    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'should be able to parse a D-M-Y string to a date' do
    date_string = '2-1-2000'
    date = Date.new(2000, 1, 2)
    f = Objective::Filters::DateFilter.new
    result = f.feed(date_string)

    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'should be able to parse a Y-M-D string to a date' do
    date_string = '2000-1-2'
    date = Date.new(2000, 1, 2)
    f = Objective::Filters::DateFilter.new
    result = f.feed(date_string)

    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'should be able to handle date formatting' do
    date_string = '2000-1-2'
    date = Date.new(2000, 1, 2)
    f = Objective::Filters::DateFilter.new(:d1, format: '%Y-%m-%d')
    result = f.feed(date_string)

    assert_equal date, result.inputs
    assert_nil result.errors

    date_string = '1, 2, 2000'
    f = Objective::Filters::DateFilter.new(:d1, format: '%m, %d, %Y')
    result = f.feed(date_string)

    assert_equal date, result.inputs
    assert_nil result.errors
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::DateFilter.new
    result = f.feed(nil)

    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'allows the use of nil when specified' do
    f = Objective::Filters::DateFilter.new(:d1, nils: true)
    result = f.feed(nil)

    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'does not allow non-existing dates' do
    date_string = '1, 20, 2013'
    f = Objective::Filters::DateFilter.new
    result = f.feed(date_string)

    assert_equal '1, 20, 2013', result.inputs
    assert_equal :date, result.errors
  end
end
