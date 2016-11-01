# frozen_string_literal: true
require 'spec_helper'
require 'stringio'
require 'tempfile'

describe 'Chaotic::Filters::FileFilter' do
  class UploadedStringIO < StringIO
    attr_accessor :content_type, :original_filename
  end

  if File.new('README.md').respond_to?(:size)
    it 'allows files - file class' do
      file = File.new('README.md')
      f = Chaotic::Filters::FileFilter.new
      filtered, errors = f.filter(file)
      assert_equal file, filtered
      assert_equal nil, errors
    end
  end

  it 'allows files - stringio class' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new
    filtered, errors = f.filter(file)
    assert_equal file, filtered
    assert_equal nil, errors
  end

  it 'allows files - tempfile' do
    file = Tempfile.new('bob')
    f = Chaotic::Filters::FileFilter.new
    filtered, errors = f.filter(file)
    assert filtered.is_a?(Tempfile)
    assert_equal nil, errors
  end

  it 'doesn\'t allow non-files' do
    f = Chaotic::Filters::FileFilter.new
    filtered, errors = f.filter('string')
    assert_equal 'string', filtered
    assert_equal :file, errors

    filtered, errors = f.filter(12)
    assert_equal 12, filtered
    assert_equal :file, errors
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::FileFilter.new(nils: false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::FileFilter.new(nils: true)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it 'considers empty strings to be empty' do
    f = Chaotic::Filters::FileFilter.new
    _filtered, errors = f.filter('')
    assert_equal :empty, errors
  end

  it 'should allow small files' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(size: 4)
    filtered, errors = f.filter(file)
    assert_equal file, filtered
    assert_equal nil, errors
  end

  it 'shouldn\'t allow big files' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(size: 2)
    filtered, errors = f.filter(file)
    assert_equal file, filtered
    assert_equal :size, errors
  end

  it 'should require extra methods if uploaded file: accept' do
    file = UploadedStringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(upload: true)
    filtered, errors = f.filter(file)
    assert_equal file, filtered
    assert_equal nil, errors
  end

  it 'should require extra methods if uploaded file: deny' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(upload: true)
    filtered, errors = f.filter(file)
    assert_equal file, filtered
    assert_equal :file, errors
  end
end
