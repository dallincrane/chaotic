require 'spec_helper'

describe "Chaotic::ModelFilter" do

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

  it "allows models" do
    f = Chaotic::ModelFilter.new(:simple_model)
    m = SimpleModel.new
    filtered, errors = f.filter(m)
    assert_equal m, filtered
    assert_equal nil, errors
  end

  # it "disallows different types of models" do
  # end

  it "raises an exception during filtering if constantization fails" do
    f = Chaotic::ModelFilter.new(:complex_model)
    assert_raises NameError do
      f.filter(nil)
    end
  end

  it "raises an exception during filtering if constantization of class fails" do
    f = Chaotic::ModelFilter.new(:simple_model, :class => "ComplexModel")
    assert_raises NameError do
      f.filter(nil)
    end
  end

  it "raises an exception during filtering if constantization of builder fails" do
    f = Chaotic::ModelFilter.new(:simple_model, :builder => "ComplexModel")
    assert_raises NameError do
      f.filter(nil)
    end
  end

  it "considers nil to be invalid" do
    f = Chaotic::ModelFilter.new(:simple_model, :nils => false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Chaotic::ModelFilter.new(:simple_model, :nils => true)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "will re-constantize if cache_constants is false" do
    was = Chaotic.cache_constants?
    Chaotic.cache_constants = false
    f = Chaotic::ModelFilter.new(:simple_model)
    m = SimpleModel.new
    filtered, errors = f.filter(m)
    assert_equal m, filtered
    assert_equal nil, errors

    Object.send(:remove_const, 'SimpleModel')

    class SimpleModel; end

    m = SimpleModel.new
    filtered, errors = f.filter(m)
    assert_equal m, filtered
    assert_equal nil, errors

    Chaotic.cache_constants = was
  end

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