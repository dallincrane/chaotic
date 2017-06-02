# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::ModelFilter' do
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
    f = Objective::Filters::ModelFilter.new(:simple_model)
    m = SimpleModel.new
    result = f.feed(m)
    assert_equal m, result.inputs
    assert_nil result.errors
  end

  it 'allows class option' do
    f = Objective::Filters::ModelFilter.new(:my_model, class: 'SimpleModel')
    m = SimpleModel.new
    result = f.feed(m)
    assert_equal m, result.inputs
    assert_nil result.errors
  end

  it 'raises an exception during filtering if constantization fails' do
    f = Objective::Filters::ModelFilter.new(:non_existent_class)

    # NOTE: nil will short circuit the check for an existing constant
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors

    assert_raises NameError do
      f.feed(0)
    end
  end

  it 'raises an exception during filtering if constantization of class fails' do
    f = Objective::Filters::ModelFilter.new(:simple_model, class: 'NonExistentClass')

    # NOTE: nil will short circuit the check for an existing constant
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors

    assert_raises NameError do
      f.feed(0)
    end
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::ModelFilter.new(:simple_model)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::ModelFilter.new(:simple_model, nils: Objective::ALLOW)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
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
