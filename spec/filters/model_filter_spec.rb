# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic::Filters::ModelFilter' do
  class SimpleModel; end
  class AlwaysNew
    def new_record?
      true
    end
  end

  class AlwaysSaved
    def new_record?
      false
    end
  end

  it 'allows models' do
    f = Chaotic::Filters::ModelFilter.new(:simple_model)
    m = SimpleModel.new
    result = f.feed(m)
    assert_equal m, result.inputs
    assert_equal nil, result.error
  end

  it 'raises an exception during filtering if constantization fails' do
    f = Chaotic::Filters::ModelFilter.new(:complex_model)
    assert_raises NameError do
      f.feed(nil)
    end
  end

  it 'raises an exception during filtering if constantization of class fails' do
    f = Chaotic::Filters::ModelFilter.new(:simple_model, class: 'ComplexModel')
    assert_raises NameError do
      f.feed(nil)
    end
  end

  it 'considers nil to be invalid' do
    f = Chaotic::Filters::ModelFilter.new(:simple_model, nils: false)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal :nils, result.error
  end

  it 'considers nil to be valid' do
    f = Chaotic::Filters::ModelFilter.new(:simple_model, nils: true)
    result = f.feed(nil)
    assert_equal nil, result.inputs
    assert_equal nil, result.error
  end

  it 'has a cache_constants default value of true' do
    assert_equal Chaotic::Filter::Options.model.cache_constants, true
  end

  it 'it will not re-constantize if cache_constants is true' do
    was = Chaotic::Filter::Options.model.cache_constants
    Chaotic::Filter::Options.model.cache_constants = true

    f = Chaotic::Filters::ModelFilter.new(:simple_model)
    m = SimpleModel.new

    result = f.feed(m)
    assert_equal m, result.inputs
    assert_equal nil, result.error

    Object.send(:remove_const, 'SimpleModel')
    class SimpleModel; end

    m = SimpleModel.new
    result = f.feed(m)
    assert_equal m, result.inputs
    assert_equal :model, result.error

    Chaotic::Filter::Options.model.cache_constants = was
  end

  it 'will re-constantize if cache_constants is false' do
    was = Chaotic::Filter::Options.model.cache_constants
    Chaotic::Filter.config { |c| c.model.cache_constants = false }

    f = Chaotic::Filters::ModelFilter.new(:simple_model)
    m = SimpleModel.new

    result = f.feed(m)
    assert_equal m, result.inputs
    assert_equal nil, result.error

    Object.send(:remove_const, 'SimpleModel')
    class SimpleModel; end

    m = SimpleModel.new
    result = f.feed(m)
    assert_equal m, result.inputs
    assert_equal nil, result.error

    Chaotic::Filter.config { |c| c.model.cache_constants = was }
  end

  # it "disallows different types of models" do
  # end
  #
  # it "allows you to override class with a constant and succeed" do
  # end
  #
  # it "allows you to override class with a string and succeed" do
  # end
  #
  # it "allows you to override class and fail" do
  # end
  #
  # it "allows anything if new_record is true" do
  # end
  #
  # it "disallows new_records if new_record is false" do
  # end
  #
  # it "allows saved records if new_record is false" do
  # end
  #
  # it "allows other records if new_record is false" do
  # end
  #
  # it "allows you to build a record from a hash, and succeed" do
  # end
  #
  # it "allows you to build a record from a hash, and fail" do
  # end
  #
  # it "makes sure that if you build a record from a hash, it still has to be of the right class" do
  # end
end
