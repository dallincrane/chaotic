# frozen_string_literal: true
require 'spec_helper'
require 'stringio'

describe 'Chaotic::Filters::HashFilter' do
  it 'allows valid hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter(foo: 'bar')
    assert_equal ({ 'foo' => 'bar' }), filtered
    assert_equal nil, errors
  end

  it 'disallows non-hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      string :foo
    end
    _filtered, errors = hf.filter('bar')
    assert_equal :hash, errors
  end

  it 'allows floats in hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      float :foo
    end
    filtered, errors = hf.filter(foo: 3.14)
    assert_equal ({ 'foo' => 3.14 }), filtered
    assert_equal nil, errors
  end

  it 'allows ducks in hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      duck :foo, methods: [:length]
    end
    filtered, errors = hf.filter(foo: '123')
    assert_equal ({ 'foo' => '123' }), filtered
    assert_equal nil, errors
  end

  it 'allows dates in hashes' do
    hf = Chaotic::Filters::HashFilter.new do
      date :foo, format: '%d-%m-%Y'
    end
    filtered, errors = hf.filter(foo: '1-1-2000')
    assert_equal Date.new(2000, 1, 1), filtered[:foo]
    assert_equal nil, errors
  end

  it 'allows files in hashes' do
    sio = StringIO.new('bob')
    hf = Chaotic::Filters::HashFilter.new do
      file :foo
    end
    filtered, errors = hf.filter(foo: sio)
    assert_equal ({ 'foo' => sio }), filtered
    assert_equal nil, errors
  end
end
