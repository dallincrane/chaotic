# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::StringFilter' do
  it 'allows valid strings' do
    sf = Objective::Filters::StringFilter.new
    result = sf.feed('hello')
    assert_equal 'hello', result.inputs
    assert_nil result.errors
  end

  it 'allows symbols' do
    sf = Objective::Filters::StringFilter.new
    result = sf.feed(:hello)
    assert_equal 'hello', result.inputs
    assert_nil result.errors
  end

  it 'allows fixnums' do
    sf = Objective::Filters::StringFilter.new
    result = sf.feed(1)
    assert_equal '1', result.inputs
    assert_nil result.errors
  end

  it 'allows bignums' do
    sf = Objective::Filters::StringFilter.new
    result = sf.feed(11_111_111_111_111_111_111)
    assert_equal '11111111111111111111', result.inputs
    assert_nil result.errors
  end

  it 'disallows non-string' do
    sf = Objective::Filters::StringFilter.new
    [['foo'], { a: '1' }, Object.new].each do |thing|
      result = sf.feed(thing)
      assert_equal :string, result.errors
    end
  end

  it 'squishes' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(" Hello,\tWorld!\r\nNew Line ")
    assert_equal 'Hello, World! New Line', result.inputs
    assert_nil result.errors
  end

  it 'does not squish' do
    sf = Objective::Filters::StringFilter.new(:s, squish: false)
    result = sf.feed(" hello \t")
    assert_equal " hello \t", result.inputs
    assert_nil result.errors
  end

  it 'considers nil to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    sf = Objective::Filters::StringFilter.new(:s, nils: Objective::ALLOW)
    result = sf.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'considers empty strings to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed('')
    assert_equal '', result.inputs
    assert_equal :empty, result.errors
  end

  it 'considers empty strings to be valid' do
    sf = Objective::Filters::StringFilter.new(:s, empty: Objective::ALLOW)
    result = sf.feed('')
    assert_equal '', result.inputs
    assert_nil result.errors
  end

  it 'considers squished strings that are empty to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed('   ')
    assert_equal '', result.inputs
    assert_equal :empty, result.errors
  end

  it 'considers strings that contain only unprintable characters to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed("\u0000\u0000")
    assert_equal '', result.inputs
    assert_equal :empty, result.errors
  end

  it 'considers long strings to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s, max: 5)
    result = sf.feed('123456')
    assert_equal '123456', result.inputs
    assert_equal :max, result.errors
  end

  it 'considers long strings to be valid' do
    sf = Objective::Filters::StringFilter.new(:s, max: 5)
    result = sf.feed('12345')
    assert_equal '12345', result.inputs
    assert_nil result.errors
  end

  it 'considers short strings to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s, min: 5)
    result = sf.feed('1234')
    assert_equal '1234', result.inputs
    assert_equal :min, result.errors
  end

  it 'considers short strings to be valid' do
    sf = Objective::Filters::StringFilter.new(:s, min: 5)
    result = sf.feed('12345')
    assert_equal '12345', result.inputs
    assert_nil result.errors
  end

  it 'considers bad matches to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s, matches: /aaa/)
    result = sf.feed('aab')
    assert_equal 'aab', result.inputs
    assert_equal :matches, result.errors
  end

  it 'considers good matches to be valid' do
    sf = Objective::Filters::StringFilter.new(:s, matches: /aaa/)
    result = sf.feed('baaab')
    assert_equal 'baaab', result.inputs
    assert_nil result.errors
  end

  it 'considers non-inclusion to be invalid' do
    sf = Objective::Filters::StringFilter.new(:s, in: %w[red blue green])
    result = sf.feed('orange')
    assert_equal 'orange', result.inputs
    assert_equal :in, result.errors
  end

  it 'considers inclusion to be valid' do
    sf = Objective::Filters::StringFilter.new(:s, in: %w[red blue green])
    result = sf.feed('red')
    assert_equal 'red', result.inputs
    assert_nil result.errors
  end

  it 'converts symbols to strings' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(:my_sym)
    assert_equal 'my_sym', result.inputs
    assert_nil result.errors
  end

  it 'converts integers to strings' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(1)
    assert_equal '1', result.inputs
    assert_nil result.errors
  end

  it 'converts bigdecimals to strings' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(BigDecimal.new('0.00000123'))
    assert_equal '0.00000123', result.inputs
    assert_nil result.errors
  end

  it 'converts bigdecimals to scientific notation strings' do
    sf = Objective::Filters::StringFilter.new(:s, decimal_format: 'E')
    result = sf.feed(BigDecimal.new('0.00000123'))
    assert_equal '0.123e-5', result.inputs
    assert_nil result.errors
  end

  it 'converts floats to strings' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(0.0001)
    assert_equal '0.0001', result.inputs
    assert_nil result.errors
  end

  it 'converts booleans to strings' do
    sf = Objective::Filters::StringFilter.new(:s)
    result = sf.feed(true)
    assert_equal 'true', result.inputs
    assert_nil result.errors
  end

  it 'disallows symbols' do
    sf = Objective::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(:my_sym)
    assert_equal :my_sym, result.inputs
    assert_equal :string, result.errors
  end

  it 'disallows integers' do
    sf = Objective::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(1)
    assert_equal 1, result.inputs
    assert_equal :string, result.errors
  end

  it 'disallows bigdecimals' do
    sf = Objective::Filters::StringFilter.new(:s, strict: true)
    big_decimal = BigDecimal.new('0.0001')
    result = sf.feed(big_decimal)
    assert_equal big_decimal, result.inputs
    assert_equal :string, result.errors
  end

  it 'disallows floats' do
    sf = Objective::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(0.0001)
    assert_equal 0.0001, result.inputs
    assert_equal :string, result.errors
  end

  it 'disallows booleans' do
    sf = Objective::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(true)
    assert_equal true, result.inputs
    assert_equal :string, result.errors
  end
end
