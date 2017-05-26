# frozen_string_literal: true

require 'spec_helper'

describe 'Objective::Filters::TimeFilter' do
  it 'takes a Time object' do
    time = Time.now
    f = Objective::Filters::TimeFilter.new
    result = f.feed(time)
    assert_equal time, result.inputs
    assert_nil result.errors
  end

  it 'takes a Date object and converts it to a time' do
    date = Date.new
    f = Objective::Filters::TimeFilter.new
    result = f.feed(date)
    assert_equal date.to_time, result.inputs
    assert_nil result.errors
  end

  it 'takes a DateTime object and converts it to a time' do
    date = DateTime.new
    f = Objective::Filters::TimeFilter.new
    result = f.feed(date)
    assert_equal date.to_time, result.inputs
    assert_nil result.errors
  end

  it 'checks if the given time is after the min time' do
    time = Time.now
    f = Objective::Filters::TimeFilter.new(:t, min: time - 1)
    result = f.feed(time)
    assert_equal time, result.inputs
    assert_nil result.errors
  end

  it 'gives errors when the given time is before the min time' do
    time = Time.now
    f = Objective::Filters::TimeFilter.new(:t, min: time + 1)
    result = f.feed(time)
    assert_equal time, result.inputs
    assert_equal :min, result.errors
  end

  it 'checks if the given time is before the max time' do
    time = Time.now
    f = Objective::Filters::TimeFilter.new(:t, max: time + 1)
    result = f.feed(time)
    assert_equal time, result.inputs
    assert_nil result.errors
  end

  it 'gives errors when the given time is after the max time' do
    time = Time.now
    f = Objective::Filters::TimeFilter.new(:t, max: time - 1)
    result = f.feed(time)
    assert_equal time, result.inputs
    assert_equal :max, result.errors
  end

  it 'checks if the given time is in the given range' do
    time = Time.now
    f = Objective::Filters::TimeFilter.new(:t, min: time - 1, max: time + 1)
    result = f.feed(time)
    assert_equal time, result.inputs
    assert_nil result.errors
  end

  it 'should be able to parse a D-M-Y string to a time' do
    date_string = '2-1-2000'
    date = Date.new(2000, 1, 2)
    f = Objective::Filters::TimeFilter.new
    result = f.feed(date_string)
    assert_equal date.to_time, result.inputs
    assert_nil result.errors
  end

  it 'should be able to parse a Y-M-D string to a time' do
    date_string = '2000-1-2'
    date = Date.new(2000, 1, 2)
    f = Objective::Filters::TimeFilter.new
    result = f.feed(date_string)
    assert_equal date.to_time, result.inputs
    assert_nil result.errors
  end

  it 'should be able to handle time formatting' do
    time_string = '2000-1-2 12:13:14'
    time = Time.new(2000, 1, 2, 12, 13, 14)
    f = Objective::Filters::TimeFilter.new(:t, format: '%Y-%m-%d %H:%M:%S')
    result = f.feed(time_string)
    assert_equal time, result.inputs
    assert_nil result.errors

    time_string = '1, 2, 2000, 121314'
    f = Objective::Filters::TimeFilter.new(:t, format: '%m, %d, %Y, %H%M%S')
    result = f.feed(time_string)
    assert_equal time, result.inputs
    assert_nil result.errors
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::TimeFilter.new
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'allows the use of nil when specified' do
    f = Objective::Filters::TimeFilter.new(:t, nils: Objective::ALLOW)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'doesn\'t allow non-existing times' do
    invalid_time_string = '1, 20, 2013 25:13'
    f = Objective::Filters::TimeFilter.new
    result = f.feed(invalid_time_string)
    assert_equal '1, 20, 2013 25:13', result.inputs
    assert_equal :time, result.errors
  end
end
