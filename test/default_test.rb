# frozen_string_literal: true

require 'test_helper'
require 'simple_unit'

describe 'Objective - defaults' do
  class DefaultUnit
    include Objective::Unit
    filter do
      string :name, none: 'Bob Jones'
    end

    def execute
      inputs
    end
  end

  it 'should have a default if no value is passed' do
    outcome = DefaultUnit.run
    assert_equal({ 'name' => 'Bob Jones' }, outcome.result)
    assert_equal true, outcome.success
  end

  it 'should have the passed value if a value is passed' do
    outcome = DefaultUnit.run(name: 'Fred')
    assert_equal true, outcome.success
    assert_equal({ 'name' => 'Fred' }, outcome.result)
  end

  it 'should be an error if nil is passed on a required field with a default' do
    outcome = DefaultUnit.run(name: nil)
    assert_equal false, outcome.success
  end
end
