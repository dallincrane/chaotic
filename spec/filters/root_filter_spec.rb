# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::RootFilter' do
  describe 'optional filters and nils' do
    it 'bar is optional -- it works if not passed' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_nils: true
        end
      end

      outcome = hf.feed(foo: 'bar')
      assert_equal OpenStruct.new(foo: 'bar'), outcome.inputs
      assert_equal nil, outcome.errors
    end

    it 'bar is optional -- it works if nil is passed' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_nils: true
        end
      end

      outcome = hf.feed(foo: 'bar', bar: nil)
      assert_equal OpenStruct.new(foo: 'bar'), outcome.inputs
      assert_equal :nils, outcome.errors.symbolic[:bar]
    end

    it 'bar is optional -- it works if nil is passed and nils are allowed' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, nils: true, discard_nils: true
        end
      end

      outcome = hf.feed(foo: 'bar', bar: nil)
      assert_equal OpenStruct.new(foo: 'bar', bar: nil), outcome.inputs
      assert_equal nil, outcome.errors
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

      outcome = hf.feed(foo: 'bar', bar: '')
      assert_equal OpenStruct.new(foo: 'bar'), outcome.inputs
      assert_equal nil, outcome.errors
    end

    it 'bar is optional -- discards empty if it needs to be stripped' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true
        end
      end

      outcome = hf.feed(foo: 'bar', bar: ' ')
      assert_equal OpenStruct.new(foo: 'bar'), outcome.inputs
      assert_equal nil, outcome.errors
    end

    it "bar is optional -- don't discard empty if it's spaces but stripping is off" do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: true, strip: false
        end
      end

      outcome = hf.feed(foo: 'bar', bar: ' ')
      assert_equal OpenStruct.new(foo: 'bar', bar: ' '), outcome.inputs
      assert_equal nil, outcome.errors
    end

    it 'bar is optional -- errors if discard_empty is false and value is blank' do
      hf = Chaotic::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, discard_empty: false
        end
      end

      outcome = hf.feed(foo: 'bar', bar: '')
      assert_equal({ 'bar' => :empty }, outcome.errors.symbolic)
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

      outcome = hf.feed(foo: 'bar', bar: 'baz')
      assert_equal OpenStruct.new(foo: 'bar'), outcome.inputs
      assert_equal nil, outcome.errors
    end
  end
end
