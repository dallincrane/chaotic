# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::TimeFilter' do
  it 'takes a Time object' do
    time = Time.now
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(time)
    assert_equal time, result.input
    assert_equal nil, result.error
  end

  it 'takes a Date object and converts it to a time' do
    date = Date.new
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(date)
    assert_equal date.to_time, result.input
    assert_equal nil, result.error
  end

  it 'takes a DateTime object and converts it to a time' do
    date = DateTime.new
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(date)
    assert_equal date.to_time, result.input
    assert_equal nil, result.error
  end

  it 'checks if the given time is after a certain time' do
    time = Time.now
    f = Chaotic::Filters::TimeFilter.new(:t, after: time - 1)
    result = f.feed(time)
    assert_equal time, result.input
    assert_equal nil, result.error
  end

  it 'gives errors when the given time is before the after time' do
    time = Time.now
    f = Chaotic::Filters::TimeFilter.new(:t, after: time + 1)
    result = f.feed(time)
    assert_equal time, result.input
    assert_equal :after, result.error
  end

  it 'checks if the given time is before a certain time' do
    time = Time.now
    f = Chaotic::Filters::TimeFilter.new(:t, before: time + 1)
    result = f.feed(time)
    assert_equal time, result.input
    assert_equal nil, result.error
  end

  it 'gives errors when the given time is after the before time' do
    time = Time.now
    f = Chaotic::Filters::TimeFilter.new(:t, before: time - 1)
    result = f.feed(time)
    assert_equal time, result.input
    assert_equal :before, result.error
  end

  it 'checks if the given time is in the given range' do
    time = Time.now
    f = Chaotic::Filters::TimeFilter.new(:t, after: time - 1, before: time + 1)
    result = f.feed(time)
    assert_equal time, result.input
    assert_equal nil, result.error
  end

  it 'should be able to parse a D-M-Y string to a time' do
    date_string = '2-1-2000'
    date = Date.new(2000, 1, 2)
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(date_string)
    assert_equal date.to_time, result.input
    assert_equal nil, result.error
  end

  it 'should be able to parse a Y-M-D string to a time' do
    date_string = '2000-1-2'
    date = Date.new(2000, 1, 2)
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(date_string)
    assert_equal date.to_time, result.input
    assert_equal nil, result.error
  end

  it 'should be able to handle time formatting' do
    time_string = '2000-1-2 12:13:14'
    time = Time.new(2000, 1, 2, 12, 13, 14)
    f = Chaotic::Filters::TimeFilter.new(:t, format: '%Y-%m-%d %H:%M:%S')
    result = f.feed(time_string)
    assert_equal time, result.input
    assert_equal nil, result.error

    time_string = '1, 2, 2000, 121314'
    f = Chaotic::Filters::TimeFilter.new(:t, format: '%m, %d, %Y, %H%M%S')
    result = f.feed(time_string)
    assert_equal time, result.input
    assert_equal nil, result.error
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(nil)
    assert_equal nil, result.input
    assert_equal :nils, result.error
  end

  it 'allows the use of nil when specified' do
    f = Chaotic::Filters::TimeFilter.new(:t, nils: true)
    result = f.feed(nil)
    assert_equal nil, result.input
    assert_equal nil, result.error
  end

  it 'doesn\'t allow non-existing times' do
    invalid_time_string = '1, 20, 2013 25:13'
    f = Chaotic::Filters::TimeFilter.new
    result = f.feed(invalid_time_string)
    assert_equal '1, 20, 2013 25:13', result.input
    assert_equal :time, result.error
  end
end
