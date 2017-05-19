# frozen_string_literal: true
require 'spec_helper'
require 'stringio'
require 'tempfile'

describe 'Objective::Filters::FileFilter' do
  class UploadedStringIO < StringIO
    attr_accessor :content_type, :original_filename
  end

  if File.new('README.md').respond_to?(:size)
    it 'allows files - file class' do
      file = File.new('README.md')
      f = Objective::Filters::FileFilter.new
      result = f.feed(file)
      assert_equal file, result.inputs
      assert_nil result.errors
    end
  end

  it 'allows files - stringio class' do
    file = StringIO.new('bob')
    f = Objective::Filters::FileFilter.new
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_nil result.errors
  end

  it 'allows files - tempfile' do
    file = Tempfile.new('bob')
    f = Objective::Filters::FileFilter.new
    result = f.feed(file)
    assert result.inputs.is_a?(Tempfile)
    assert_nil result.errors
  end

  it 'doesn\'t allow non-files' do
    f = Objective::Filters::FileFilter.new
    result = f.feed('string')
    assert_equal 'string', result.inputs
    assert_equal :file, result.errors

    result = f.feed(12)
    assert_equal 12, result.inputs
    assert_equal :file, result.errors
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::FileFilter.new(:clippy)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::FileFilter.new(:clippy, nils: Objective::ALLOW)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'should allow small files' do
    file = StringIO.new('bob')
    f = Objective::Filters::FileFilter.new(:clippy, size: 4)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_nil result.errors
  end

  it 'shouldn\'t allow big files' do
    file = StringIO.new('bob')
    f = Objective::Filters::FileFilter.new(:clippy, size: 2)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal :size, result.errors
  end

  it 'should require extra methods if uploaded file: accept' do
    file = UploadedStringIO.new('bob')
    f = Objective::Filters::FileFilter.new(:clippy, upload: true)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_nil result.errors
  end

  it 'should require extra methods if uploaded file: deny' do
    file = StringIO.new('bob')
    f = Objective::Filters::FileFilter.new(:clippy, upload: true)
    result = f.feed(file)
    assert_equal file, result.inputs
    assert_equal :file, result.errors
  end
end
