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

  describe 'optional params and nils' do
    it 'bar is optional -- it works if not passed' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, required: false
        end
      end

      filtered, errors = hf.filter(foo: 'bar')
      assert_equal ({ 'foo' => 'bar' }), filtered
      assert_equal nil, errors
    end

    it 'bar is optional -- it does not work if nil is passed' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, required: false
        end
      end

      filtered, errors = hf.filter(foo: 'bar', bar: nil)
      assert_equal ({ 'foo' => 'bar', 'bar' => nil }), filtered
      assert_equal :nils, errors.symbolic[:bar]
    end

    it 'bar is optional -- it works if nil is passed and nils are allowed' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, nils: true, required: false
        end
      end

      filtered, errors = hf.filter(foo: 'bar', bar: nil)
      assert_equal ({ 'foo' => 'bar', 'bar' => nil }), filtered
      assert_equal nil, errors
    end
  end

  describe 'optional params and empty values' do
    it 'bar is optional -- discards empty' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, discard_empty: true
        end
      end

      filtered, errors = hf.filter(foo: 'bar', bar: '')
      assert_equal ({ 'foo' => 'bar' }), filtered
      assert_equal nil, errors
    end

    it 'bar is optional -- discards empty if it needs to be stripped' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, discard_empty: true
        end
      end

      filtered, errors = hf.filter(foo: 'bar', bar: ' ')
      assert_equal ({ 'foo' => 'bar' }), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- don't discard empty if it's spaces but stripping is off" do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, discard_empty: true, strip: false
        end
      end

      filtered, errors = hf.filter(foo: 'bar', bar: ' ')
      assert_equal ({ 'foo' => 'bar', 'bar' => ' ' }), filtered
      assert_equal nil, errors
    end

    it 'bar is optional -- errors if discard_empty is false and value is blank' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          string :bar, discard_empty: false
        end
      end

      _filtered, errors = hf.filter(foo: 'bar', bar: '')
      assert_equal ({ 'bar' => :empty }), errors.symbolic
    end
  end

  describe 'discarding invalid values' do
    it 'should discard invalid optional values' do
      hf = Chaotic::Filters::HashFilter.new do
        params do
          string :foo
          integer :bar, discard_invalid: true
        end
      end

      filtered, errors = hf.filter(foo: 'bar', bar: 'baz')
      assert_equal ({ 'foo' => 'bar' }), filtered
      assert_equal nil, errors
    end
  end
end
