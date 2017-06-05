# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::SymbolFilter' do
  it 'allows symbols' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    result = sf.feed(:wubba)
    assert_equal :wubba, result.inputs
    assert_nil result.errors
  end

  it 'allows strings' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    result = sf.feed('wubba')
    assert_equal :wubba, result.inputs
    assert_nil result.errors
  end

  it 'allows strings that need to be stripped' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    result = sf.feed(" wubba \n  ")
    assert_equal :wubba, result.inputs
    assert_nil result.errors
  end

  it 'disallows other data types' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    [['foo'], { a: :b }, Object.new, true, false, 1, 3.14].each do |thing|
      result = sf.feed(thing)
      assert_equal :symbol, result.errors
    end
  end

  it 'considers nil to be invalid' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    result = sf.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'can consider nil to be valid' do
    sf = Objective::Filters::SymbolFilter.new(:sym, nils: Objective::ALLOW)
    result = sf.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'considers empty strings to be invalid' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    result = sf.feed('')
    assert_equal '', result.inputs
    assert_equal :empty, result.errors
  end

  it 'can consider empty strings to be nil' do
    sf = Objective::Filters::SymbolFilter.new(:sym, empty: nil)
    result = sf.feed('')
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'can consider empty strings to be other values' do
    sf = Objective::Filters::SymbolFilter.new(:sym, empty: 'wubba')
    result = sf.feed('')
    assert 'wubba', result.inputs
    assert_nil result.errors
  end

  it 'considers stripped strings that are empty to be invalid' do
    sf = Objective::Filters::SymbolFilter.new(:sym)
    result = sf.feed('   ')
    assert_equal '', result.inputs
    assert_equal :empty, result.errors
  end

  it 'considers non-inclusion to be invalid' do
    sf = Objective::Filters::SymbolFilter.new(:sym, in: %i[red blue green])
    result = sf.feed(:orange)
    assert_equal :orange, result.inputs
    assert_equal :in, result.errors
  end

  it 'considers inclusion to be valid' do
    sf = Objective::Filters::SymbolFilter.new(:sym, in: %i[red blue green])
    result = sf.feed(:red)
    assert_equal :red, result.inputs
    assert_nil result.errors
  end
end
