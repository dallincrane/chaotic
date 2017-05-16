# frozen_string_literal: true
require 'spec_helper'

describe 'Objective::Filters::RootFilter' do
  describe 'optional filters and nils' do
    it 'bar is optional -- it works if not passed' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_nils: true
        end
      end

      result = hf.feed(foo: 'bar')
      assert_equal OpenStruct.new(foo: 'bar'), result.inputs
      assert_nil result.errors
    end

    it 'bar is optional -- it works if nil is passed' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_nils: true
        end
      end

      result = hf.feed(foo: 'bar', bar: nil)
      assert_equal OpenStruct.new(foo: 'bar'), result.inputs
      assert_nil result.errors
    end

    it 'bar is optional -- it works if nil is passed and nils are allowed' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, nils: true, discard_nils: true
        end
      end

      result = hf.feed(foo: 'bar', bar: nil)
      assert_equal OpenStruct.new(foo: 'bar', bar: nil), result.inputs
      assert_nil result.errors
    end
  end

  describe 'optional filters and empty values' do
    it 'bar is optional -- discards empty' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true
        end
      end

      result = hf.feed(foo: 'bar', bar: '')
      assert_equal OpenStruct.new(foo: 'bar'), result.inputs
      assert_nil result.errors
    end

    it 'bar is optional -- discards empty if it needs to be stripped' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true
        end
      end

      result = hf.feed(foo: 'bar', bar: ' ')
      assert_equal OpenStruct.new(foo: 'bar'), result.inputs
      assert_nil result.errors
    end

    it "bar is optional -- don't discard empty if it's spaces but stripping is off" do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true, strip: false
        end
      end

      result = hf.feed(foo: 'bar', bar: ' ')
      assert_equal OpenStruct.new(foo: 'bar', bar: ' '), result.inputs
      assert_nil result.errors
    end

    it 'bar is optional -- errors if discard_empty is false and value is blank' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: false
        end
      end

      result = hf.feed(foo: 'bar', bar: '')
      assert_equal({ 'bar' => :empty }, result.errors.codes)
    end
  end

  describe 'discarding invalid values' do
    it 'should discard invalid optional values' do
      hf = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          integer :bar, discard_invalid: true
        end
      end

      result = hf.feed(foo: 'bar', bar: 'baz')
      assert_equal OpenStruct.new(foo: 'bar'), result.inputs
      assert_nil result.errors
    end
  end
end
