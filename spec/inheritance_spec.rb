# frozen_string_literal: true
require 'spec_helper'
require 'simple_command'

describe 'Chaotic - inheritance' do
  class SimpleInherited < SimpleCommand
    params do
      integer :age
    end

    def execute
    end
  end

  it 'should filter with inherited command' do
    outcome = SimpleInherited.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
    assert outcome.success
    assert_equal OpenStruct.new(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22), outcome.inputs
  end

  it 'should filter with original command' do
    outcome = SimpleCommand.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
    assert outcome.success
    assert_equal OpenStruct.new(name: 'bob', email: 'jon@jones.com', amount: 22), outcome.inputs
  end

  it 'shouldnt collide' do
    outcome = SimpleInherited.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
    assert outcome.success
    assert_equal OpenStruct.new(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22), outcome.inputs

    outcome = SimpleCommand.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
    assert outcome.success
    assert_equal OpenStruct.new(name: 'bob', email: 'jon@jones.com', amount: 22), outcome.inputs
  end
end
