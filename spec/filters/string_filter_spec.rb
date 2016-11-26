# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::StringFilter' do
  it 'allows valid strings' do
    sf = Chaotic::Filters::StringFilter.new
    filtered, errors = sf.feed('hello')
    assert_equal 'hello', filtered
    assert_equal nil, errors
  end

  it 'allows symbols' do
    sf = Chaotic::Filters::StringFilter.new
    filtered, errors = sf.feed(:hello)
    assert_equal 'hello', filtered
    assert_equal nil, errors
  end

  it 'allows fixnums' do
    sf = Chaotic::Filters::StringFilter.new
    filtered, errors = sf.feed(1)
    assert_equal '1', filtered
    assert_equal nil, errors
  end

  it 'allows bignums' do
    sf = Chaotic::Filters::StringFilter.new
    filtered, errors = sf.feed(11_111_111_111_111_111_111)
    assert_equal '11111111111111111111', filtered
    assert_equal nil, errors
  end

  it 'disallows non-string' do
    sf = Chaotic::Filters::StringFilter.new
    [['foo'], { a: '1' }, Object.new].each do |thing|
      _filtered, errors = sf.feed(thing)
      assert_equal :string, errors
    end
  end

  it 'strips' do
    sf = Chaotic::Filters::StringFilter.new(:s, strip: true)
    filtered, errors = sf.feed(' hello ')
    assert_equal 'hello', filtered
    assert_equal nil, errors
  end

  it 'doesn\'t strip' do
    sf = Chaotic::Filters::StringFilter.new(:s, strip: false)
    filtered, errors = sf.feed(' hello ')
    assert_equal ' hello ', filtered
    assert_equal nil, errors
  end

  it 'considers nil to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, nils: false)
    filtered, errors = sf.feed(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it 'considers nil to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, nils: true)
    filtered, errors = sf.feed(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it 'considers empty strings to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: false)
    filtered, errors = sf.feed('')
    assert_equal '', filtered
    assert_equal :empty, errors
  end

  it 'considers empty strings to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: true)
    filtered, errors = sf.feed('')
    assert_equal '', filtered
    assert_equal nil, errors
  end

  it 'considers stripped strings that are empty to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: false)
    filtered, errors = sf.feed('   ')
    assert_equal '', filtered
    assert_equal :empty, errors
  end

  it 'considers strings that contain only unprintable characters to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, empty: false)
    filtered, errors = sf.feed("\u0000\u0000")
    assert_equal '', filtered
    assert_equal :empty, errors
  end

  it 'considers long strings to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, max_length: 5)
    filtered, errors = sf.feed('123456')
    assert_equal '123456', filtered
    assert_equal :max_length, errors
  end

  it 'considers long strings to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, max_length: 5)
    filtered, errors = sf.feed('12345')
    assert_equal '12345', filtered
    assert_equal nil, errors
  end

  it 'considers short strings to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, min_length: 5)
    filtered, errors = sf.feed('1234')
    assert_equal '1234', filtered
    assert_equal :min_length, errors
  end

  it 'considers short strings to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, min_length: 5)
    filtered, errors = sf.feed('12345')
    assert_equal '12345', filtered
    assert_equal nil, errors
  end

  it 'considers bad matches to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, matches: /aaa/)
    filtered, errors = sf.feed('aab')
    assert_equal 'aab', filtered
    assert_equal :matches, errors
  end

  it 'considers good matches to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, matches: /aaa/)
    filtered, errors = sf.feed('baaab')
    assert_equal 'baaab', filtered
    assert_equal nil, errors
  end

  it 'considers non-inclusion to be invalid' do
    sf = Chaotic::Filters::StringFilter.new(:s, in: %w(red blue green))
    filtered, errors = sf.feed('orange')
    assert_equal 'orange', filtered
    assert_equal :in, errors
  end

  it 'considers inclusion to be valid' do
    sf = Chaotic::Filters::StringFilter.new(:s, in: %w(red blue green))
    filtered, errors = sf.feed('red')
    assert_equal 'red', filtered
    assert_equal nil, errors
  end

  it 'converts symbols to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    filtered, errors = sf.feed(:my_sym)
    assert_equal 'my_sym', filtered
    assert_equal nil, errors
  end

  it 'converts integers to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    filtered, errors = sf.feed(1)
    assert_equal '1', filtered
    assert_equal nil, errors
  end

  it 'converts bigdecimals to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    filtered, errors = sf.feed(BigDecimal.new('0.0001'))
    assert_equal '0.1E-3', filtered
    assert_equal nil, errors
  end

  it 'converts floats to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    filtered, errors = sf.feed(0.0001)
    assert_equal '0.0001', filtered
    assert_equal nil, errors
  end

  it 'converts booleans to strings' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: false)
    filtered, errors = sf.feed(true)
    assert_equal 'true', filtered
    assert_equal nil, errors
  end

  it 'disallows symbols' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    filtered, errors = sf.feed(:my_sym)
    assert_equal :my_sym, filtered
    assert_equal :string, errors
  end

  it 'disallows integers' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    filtered, errors = sf.feed(1)
    assert_equal 1, filtered
    assert_equal :string, errors
  end

  it 'disallows bigdecimals' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    big_decimal = BigDecimal.new('0.0001')
    filtered, errors = sf.feed(big_decimal)
    assert_equal big_decimal, filtered
    assert_equal :string, errors
  end

  it 'disallows floats' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    filtered, errors = sf.feed(0.0001)
    assert_equal 0.0001, filtered
    assert_equal :string, errors
  end

  it 'disallows booleans' do
    sf = Chaotic::Filters::StringFilter.new(:s, strict: true)
    filtered, errors = sf.feed(true)
    assert_equal true, filtered
    assert_equal :string, errors
  end

  it 'removes unprintable characters' do
    sf = Chaotic::Filters::StringFilter.new(:s, allow_control_characters: false)
    filtered, errors = sf.feed("Hello\u0000\u0000World!")
    assert_equal 'Hello World!', filtered
    assert_equal nil, errors
  end

  it "doesn't remove unprintable characters" do
    sf = Chaotic::Filters::StringFilter.new(:s, allow_control_characters: true)
    filtered, errors = sf.feed("Hello\u0000\u0000World!")
    assert_equal "Hello\u0000\u0000World!", filtered
    assert_equal nil, errors
  end

  it "doesn't remove tabs, spaces and line breaks" do
    sf = Chaotic::Filters::StringFilter.new(:s, allow_control_characters: false)
    filtered, errors = sf.feed("Hello,\tWorld !\r\nNew Line")
    assert_equal "Hello,\tWorld !\r\nNew Line", filtered
    assert_equal nil, errors
  end
end
