# frozen_string_literal: true
require 'spec_helper'
require 'stringio'

describe 'Chaotic::Filters::HashFilter' do
  it 'allows valid hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      string :foo
    end

    result = hf.feed(foo: 'bar')
    assert_equal ({ 'foo' => 'bar' }), result.inputs
    assert_equal nil, result.error
  end

  it 'disallows non-hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      string :foo
    end

    result = hf.feed('bar')
    assert_equal :hash, result.error
  end

  it 'allows floats in hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      float :foo
    end

    result = hf.feed(foo: 3.14)
    assert_equal ({ 'foo' => 3.14 }), result.inputs
    assert_equal nil, result.error
  end

  it 'allows ducks in hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      duck :foo, methods: [:length]
    end

    result = hf.feed(foo: '123')
    assert_equal ({ 'foo' => '123' }), result.inputs
    assert_equal nil, result.error
  end

  it 'allows dates in hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      date :foo, format: '%d-%m-%Y'
    end

    result = hf.feed(foo: '1-1-2000')
    assert_equal Date.new(2000, 1, 1), result.inputs[:foo]
    assert_equal nil, result.error
  end

  it 'allows files in hashes' do
    sio = StringIO.new('bob')
    hf = Chaotic::Filters::HashFilter.new do
      file :foo
    end

    result = hf.feed(foo: sio)
    assert_equal ({ 'foo' => sio }), result.inputs
    assert_equal nil, result.error
  end
end
