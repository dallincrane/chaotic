# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::RootFilter' do
  describe 'by default' do
    it 'does not allow missing keys' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar
        end
      end

      result = f.feed(foo: 'oof')
      assert_equal :nils, result.errors[:bar].codes
    end

    it 'does not allow nil values' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar
        end
      end

      result = f.feed(foo: 'oof', bar: nil)
      assert_equal :nils, result.errors[:bar].codes
    end

    it 'does not allow empty values' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar
        end
      end

      result = f.feed(foo: 'oof', bar: ' ')
      assert_equal :empty, result.errors[:bar].codes
    end
  end

  describe 'when nils are allowed' do
    it 'can accept a nil value' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, nils: Objective::ALLOW
        end
      end

      result = f.feed(foo: 'oof', bar: nil)
      assert_equal({ 'foo' => 'oof', 'bar' => nil }, result.inputs)
      assert_nil result.errors
    end

    it 'uses nil when a value is not passed' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, nils: Objective::ALLOW
        end
      end

      result = f.feed(foo: 'oof')
      assert_equal({ 'foo' => 'oof', 'bar' => nil }, result.inputs)
      assert_nil result.errors
    end
  end

  describe 'when empty values are allowed' do
    it 'can accept an empty value' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, empty: Objective::ALLOW
        end
      end

      result = f.feed(foo: 'bar', bar: '')
      assert_equal({ 'foo' => 'bar', 'bar' => '' }, result.inputs)
      assert_nil result.errors
    end

    it 'can default a nil value to being empty' do
      f = Objective::Filters::RootFilter.new do
        filter do
          string :foo
          string :bar, empty: Objective::ALLOW, nils: ''
        end
      end

      result = f.feed(foo: 'bar', bar: '')
      assert_equal({ 'foo' => 'bar', 'bar' => '' }, result.inputs)
      assert_nil result.errors
    end
  end
end
