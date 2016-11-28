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
      result = f.feed(file)
      assert_equal file, result.inputs
      assert_equal nil, result.error
    end
  end

  it 'allows files - stringio class' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal nil, result.error
  end

  it 'allows files - tempfile' do
    file = Tempfile.new('bob')
    f = Chaotic::Filters::FileFilter.new
    result = f.feed(file)
    assert result.inputs.is_a?(Tempfile)
    assert_equal nil, result.error
  end

  it 'doesn\'t allow non-files' do
    f = Chaotic::Filters::FileFilter.new
    result = f.feed('string')
    assert_equal 'string', result.inputs
    assert_equal :file, result.error

    result = f.feed(12)
    assert_equal 12, result.inputs
    assert_equal :file, result.error
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::FileFilter.new(:clippy, nils: false)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::FileFilter.new(:clippy, nils: true)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal nil, result.error
  end

  it 'should allow small files' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(:clippy, size: 4)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal nil, result.error
  end

  it 'shouldn\'t allow big files' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(:clippy, size: 2)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal :size, result.error
  end

  it 'should require extra methods if uploaded file: accept' do
    file = UploadedStringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(:clippy, upload: true)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal nil, result.error
  end

  it 'should require extra methods if uploaded file: deny' do
    file = StringIO.new('bob')
    f = Chaotic::Filters::FileFilter.new(:clippy, upload: true)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal :file, result.error
  end
end
