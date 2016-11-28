# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::StringFilter' do
  it 'allows valid strings' do
    sf = Chaotic::Filters::StringFilter.new
    result = sf.feed('hello')
    assert_equal 'hello', result.input
    assert_equal nil, result.error
  end

  it 'allows symbols' do
    sf = Chaotic::Filters::StringFilter.new
    result = sf.feed(:hello)
    assert_equal 'hello', result.input
    assert_equal nil, result.error
  end

  it 'allows fixnums' do
    sf = Chaotic::Filters::StringFilter.new
    result = sf.feed(1)
    assert_equal '1', result.input
    assert_equal nil, result.error
  end

  it 'allows bignums' do
    sf = Chaotic::Filters::StringFilter.new
    result = sf.feed(11_111_111_111_111_111_111)
    assert_equal '11111111111111111111', result.input
    assert_equal nil, result.error
  end

  it 'disallows non-string' do
    sf = Chaotic::Filters::StringFilter.new
    [['foo'], { a: '1' }, Object.new].each do |thing|
      result = sf.feed(thing)
      assert_equal :string, result.error
    end
  end

  it 'strips' do
    sf = Chaotic::Filters::StringFilter.new(:s, strip: true)
    result = sf.feed(' hello ')
    assert_equal 'hello', result.input
    assert_equal nil, result.error
  end

  it 'doesn\'t strip' do
    sf = Chaotic::Filters::StringFilter.new(:s, strip: false)
    result = sf.feed(' hello ')
    assert_equal ' hello ', result.input
    assert_equal nil, result.error
  end

  it 'considers nil to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, nils: false)
    result = sf.feed(nil)
    assert_equal nil, result.input
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, nils: true)
    result = sf.feed(nil)
    assert_equal nil, result.input
    assert_equal nil, result.error
  end

  it 'considers empty strings to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: false)
    result = sf.feed('')
    assert_equal '', result.input
    assert_equal :empty, result.error
  end

  it 'considers empty strings to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: true)
    result = sf.feed('')
    assert_equal '', result.input
    assert_equal nil, result.error
  end

  it 'considers stripped strings that are empty to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: false)
    result = sf.feed('   ')
    assert_equal '', result.input
    assert_equal :empty, result.error
  end

  it 'considers strings that contain only unprintable characters to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: false)
    result = sf.feed("\u0000\u0000")
    assert_equal '', result.input
    assert_equal :empty, result.error
  end

  it 'considers long strings to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, max_length: 5)
    result = sf.feed('123456')
    assert_equal '123456', result.input
    assert_equal :max_length, result.error
  end

  it 'considers long strings to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, max_length: 5)
    result = sf.feed('12345')
    assert_equal '12345', result.input
    assert_equal nil, result.error
  end

  it 'considers short strings to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, min_length: 5)
    result = sf.feed('1234')
    assert_equal '1234', result.input
    assert_equal :min_length, result.error
  end

  it 'considers short strings to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, min_length: 5)
    result = sf.feed('12345')
    assert_equal '12345', result.input
    assert_equal nil, result.error
  end

  it 'considers bad matches to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, matches: /aaa/)
    result = sf.feed('aab')
    assert_equal 'aab', result.input
    assert_equal :matches, result.error
  end

  it 'considers good matches to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, matches: /aaa/)
    result = sf.feed('baaab')
    assert_equal 'baaab', result.input
    assert_equal nil, result.error
  end

  it 'considers non-inclusion to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, in: %w(red blue green))
    result = sf.feed('orange')
    assert_equal 'orange', result.input
    assert_equal :in, result.error
  end

  it 'considers inclusion to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, in: %w(red blue green))
    result = sf.feed('red')
    assert_equal 'red', result.input
    assert_equal nil, result.error
  end

  it 'converts symbols to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    result = sf.feed(:my_sym)
    assert_equal 'my_sym', result.input
    assert_equal nil, result.error
  end

  it 'converts integers to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    result = sf.feed(1)
    assert_equal '1', result.input
    assert_equal nil, result.error
  end

  it 'converts bigdecimals to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    result = sf.feed(BigDecimal.new('0.0001'))
    assert_equal '0.1E-3', result.input
    assert_equal nil, result.error
  end

  it 'converts floats to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    result = sf.feed(0.0001)
    assert_equal '0.0001', result.input
    assert_equal nil, result.error
  end

  it 'converts booleans to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    result = sf.feed(true)
    assert_equal 'true', result.input
    assert_equal nil, result.error
  end

  it 'disallows symbols' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(:my_sym)
    assert_equal :my_sym, result.input
    assert_equal :string, result.error
  end

  it 'disallows integers' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(1)
    assert_equal 1, result.input
    assert_equal :string, result.error
  end

  it 'disallows bigdecimals' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    big_decimal = BigDecimal.new('0.0001')
    result = sf.feed(big_decimal)
    assert_equal big_decimal, result.input
    assert_equal :string, result.error
  end

  it 'disallows floats' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(0.0001)
    assert_equal 0.0001, result.input
    assert_equal :string, result.error
  end

  it 'disallows booleans' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    result = sf.feed(true)
    assert_equal true, result.input
    assert_equal :string, result.error
  end

  it 'removes unprintable characters' do
    sf = Chaotic::Filters::StringFilter.new(:s, allow_control_characters: false)
    result = sf.feed("Hello\u0000\u0000World!")
    assert_equal 'Hello World!', result.input
    assert_equal nil, result.error
  end

  it "doesn't remove unprintable characters" do
    sf = Chaotic::Filters::StringFilter.new(:s, allow_control_characters: true)
    result = sf.feed("Hello\u0000\u0000World!")
    assert_equal "Hello\u0000\u0000World!", result.input
    assert_equal nil, result.error
  end

  it "doesn't remove tabs, spaces and line breaks" do
    sf = Chaotic::Filters::StringFilter.new(:s, allow_control_characters: false)
    result = sf.feed("Hello,\tWorld !\r\nNew Line")
    assert_equal "Hello,\tWorld !\r\nNew Line", result.input
    assert_equal nil, result.error
  end
end
