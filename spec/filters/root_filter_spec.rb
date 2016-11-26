# frozen_string_literal: true
require 'spec_helper'
require 'stringio'

describe 'Chaotic::Filters::RootFilter' do
  describe 'optional filters and nils' do
    it 'bar is optional -- it works if not passed' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, required: false
        end
      end

      filtered, errors = hf.feed(foo: 'bar').values
      assert_equal OpenStruct.new(foo: 'bar'), filtered
      assert_equal nil, errors
    end

    it 'bar is optional -- it does not work if nil is passed' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, required: false
        end
      end

      filtered, errors = hf.feed(foo: 'bar', bar: nil).values
      assert_equal OpenStruct.new(foo: 'bar', bar: nil), filtered
      assert_equal :nils, errors.symbolic[:bar]
    end

    it 'bar is optional -- it works if nil is passed and nils are allowed' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, nils: true, required: false
        end
      end

      filtered, errors = hf.feed(foo: 'bar', bar: nil).values
      assert_equal OpenStruct.new(foo: 'bar', bar: nil), filtered
      assert_equal nil, errors
    end
  end

  describe 'optional filters and empty values' do
    it 'bar is optional -- discards empty' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true
        end
      end

      filtered, errors = hf.feed(foo: 'bar', bar: '').values
      assert_equal OpenStruct.new(foo: 'bar'), filtered
      assert_equal nil, errors
    end

    it 'bar is optional -- discards empty if it needs to be stripped' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true
        end
      end

      filtered, errors = hf.feed(foo: 'bar', bar: ' ').values
      assert_equal OpenStruct.new(foo: 'bar'), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- don't discard empty if it's spaces but stripping is off" do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true, strip: false
        end
      end

      filtered, errors = hf.feed(foo: 'bar', bar: ' ').values
      assert_equal OpenStruct.new(foo: 'bar', bar: ' '), filtered
      assert_equal nil, errors
    end

    it 'bar is optional -- errors if discard_empty is false and value is blank' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: false
        end
      end

      _filtered, errors = hf.feed(foo: 'bar', bar: '').values
      assert_equal({ 'bar' => :empty }, errors.symbolic)
    end
  end

  describe 'discarding invalid values' do
    it 'should discard invalid optional values' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          integer :bar, discard_invalid: true
        end
      end

      filtered, errors = hf.feed(foo: 'bar', bar: 'baz').values
      assert_equal OpenStruct.new(foo: 'bar'), filtered
      assert_equal nil, errors
    end
  end
end
