# frozen_string_literal: true

require 'test_helper'
require 'simple_unit'

describe 'Objective - defaults' do
  class DefaultUnit
    include Objective::Unit

    filter do
      string :name, nils: '-nils-', invalid: '-invalid-', empty: '-empty-'
    end

    def execute
      inputs
    end
  end

  it 'should use a valid value passed to it' do
    outcome = DefaultUnit.run(name: 'Fred')
    assert_equal true, outcome.success
    assert_equal({ 'name' => 'Fred' }, outcome.result)
  end

  it 'should use a nils option default value if no value is passed' do
    outcome = DefaultUnit.run
    assert_equal({ 'name' => '-nils-' }, outcome.result)
    assert_equal true, outcome.success
  end

  it 'should use a nils option default value if nil is passed' do
    outcome = DefaultUnit.run(name: nil)
    assert_equal({ 'name' => '-nils-' }, outcome.result)
    assert_equal true, outcome.success
  end

  it 'should use the invalid option default if an invalid value is passed' do
    outcome = DefaultUnit.run(name: /regex/)
    assert_equal({ 'name' => '-invalid-' }, outcome.result)
    assert_equal true, outcome.success
  end

  it 'should use the empty option default if an empty value is passed' do
    outcome = DefaultUnit.run(name: ' ')
    assert_equal({ 'name' => '-empty-' }, outcome.result)
    assert_equal true, outcome.success
  end
end
