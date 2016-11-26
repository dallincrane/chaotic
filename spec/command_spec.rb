# frozen_string_literal: true
require 'spec_helper'
require 'simple_command'

describe 'Command' do
  describe 'SimpleCommand' do
    it 'should allow valid input' do
      outcome = SimpleCommand.run(name: 'John', email: 'john@gmail.com', amount: 5)

      assert outcome.success
      assert_equal OpenStruct.new(name: 'John', email: 'john@gmail.com', amount: 5), outcome.inputs
      assert_equal nil, outcome.errors
    end

    it 'should filter out extra inputs' do
      outcome = SimpleCommand.run(name: 'John', email: 'john@gmail.com', amount: 5, buggers: true)

      assert outcome.success
      assert_equal OpenStruct.new(name: 'John', email: 'john@gmail.com', amount: 5), outcome.inputs
      assert_equal nil, outcome.errors
    end

    it 'should discover errors in inputs' do
      outcome = SimpleCommand.run(name: 'JohnTooLong', email: 'john@gmail.com')

      assert !outcome.success
      assert_equal :max_length, outcome.errors.symbolic[:name]
    end

    it 'shouldn\'t throw an exception with run!' do
      result = SimpleCommand.run!(name: 'John', email: 'john@gmail.com', amount: 5)
      assert_equal(nil, result)
    end

    it 'should throw an exception with run!' do
      assert_raises Chaotic::ValidationError do
        SimpleCommand.run!(name: 'John', email: 'john@gmail.com', amount: 'bob')
      end
    end

    it 'should do standalone validation' do
      outcome = SimpleCommand.build(name: 'JohnLong', email: 'john@gmail.com')
      assert outcome.success
      assert_nil outcome.errors

      outcome = SimpleCommand.build(name: 'JohnTooLong', email: 'john@gmail.com')
      assert !outcome.success
      assert_nil outcome.result
      assert_equal :max_length, outcome.errors.symbolic[:name]
    end

    it 'should execute a custom validate method' do
      outcome = SimpleCommand.build(name: 'JohnLong', email: 'xxxx')

      assert !outcome.success
      assert_equal :invalid, outcome.errors.symbolic[:email]
    end

    it 'should execute custom validate method during run' do
      outcome = SimpleCommand.run(name: 'JohnLong', email: 'xxxx')

      assert !outcome.success
      assert_nil outcome.result
      assert_equal :invalid, outcome.errors.symbolic[:email]
    end

    it 'should execute custom validate method only if regular validations succeed' do
      outcome = SimpleCommand.build(name: 'JohnTooLong', email: 'xxxx')

      assert !outcome.success
      assert_equal :max_length, outcome.errors.symbolic[:name]
      assert_equal nil, outcome.errors.symbolic[:email]
    end

    it 'should merge multiple hashes' do
      outcome = SimpleCommand.run({ name: 'John', email: 'john@gmail.com' }, email: 'bob@jones.com', amount: 5)

      assert outcome.success
      assert_equal OpenStruct.new(name: 'John', email: 'bob@jones.com', amount: 5), outcome.inputs
    end

    it 'should merge hashes indifferently' do
      outcome = SimpleCommand.run({ name: 'John', email: 'john@gmail.com' }, 'email' => 'bob@jones.com', 'amount' => 5)

      assert outcome.success
      assert_equal OpenStruct.new(name: 'John', email: 'bob@jones.com', amount: 5), outcome.inputs
    end

    it 'shouldn\'t accept non-hashes' do
      assert_raises ArgumentError do
        SimpleCommand.run(nil)
      end

      assert_raises ArgumentError do
        SimpleCommand.run(1)
      end

      assert_raises ArgumentError do
        SimpleCommand.run({ name: 'John' }, 1)
      end
    end

    it 'should accept nothing at all' do
      SimpleCommand.run # make sure nothing is raised
    end

    it 'should return the filtered inputs in the outcome' do
      outcome = SimpleCommand.run(name: ' John ', email: 'john@gmail.com', amount: '5')
      assert_equal(OpenStruct.new(name: 'John', email: 'john@gmail.com', amount: 5), outcome.inputs)
    end
  end

  describe 'EigenCommand' do
    class EigenCommand
      include Chaotic::Command
      filter do
        string :name
        string :email, required: false
      end

      def execute
        { name: name, email: email }
      end
    end

    it 'should define methods for input keys' do
      outcome = EigenCommand.run(name: 'John', email: 'john@gmail.com')
      assert_equal({ name: 'John', email: 'john@gmail.com' }, outcome.result)
    end
  end

  describe 'MutatatedCommand' do
    class MutatatedCommand
      include Chaotic::Command
      filter do
        string :name
        string :email, required: false
      end

      def execute
        inputs.name = 'bob'
        inputs.email = 'bob@jones.com'
        { name: inputs[:name], email: inputs[:email] }
      end
    end

    it 'should allow inputs to be changed' do
      outcome = MutatatedCommand.run(name: 'John', email: 'john@gmail.com')
      assert_equal({ name: 'bob', email: 'bob@jones.com' }, outcome.result)
    end
  end

  describe 'ErrorfulCommand' do
    class ErrorfulCommand
      include Chaotic::Command
      filter do
        string :name
        string :email, required: false
      end

      def execute
        add_error('bob', :is_a_bob)
        1
      end
    end

    it 'should let you add errors' do
      outcome = ErrorfulCommand.run(name: 'John', email: 'john@gmail.com')

      assert !outcome.success
      assert 1, outcome.result
      assert :is_a_bob, outcome.errors.symbolic[:bob]
    end
  end

  describe 'NestingErrorfulCommand' do
    class NestingErrorfulCommand
      include Chaotic::Command
      filter do
        string :name
        string :email, required: false
      end

      def execute
        add_error('people.bob', :is_a_bob)
        1
      end
    end

    it 'should let you add errors nested under a namespace' do
      outcome = NestingErrorfulCommand.run(name: 'John', email: 'john@gmail.com')

      assert !outcome.success
      assert 1, outcome.result
      assert :is_a_bob, outcome.errors[:people].symbolic[:bob]
    end
  end

  describe 'MultiErrorCommand' do
    class MultiErrorCommand
      include Chaotic::Command
      filter do
        string :name
        string :email, required: false
      end

      def execute
        moar_errors = Chaotic::Errors::ErrorHash.new
        moar_errors[:bob] = Chaotic::Errors::ErrorAtom.new(:bob, :is_short)
        moar_errors[:sally] = Chaotic::Errors::ErrorAtom.new(:sally, :is_fat)

        merge_errors(moar_errors)
        1
      end
    end

    it 'should let you merge errors' do
      outcome = ErrorfulCommand.run(name: 'John', email: 'john@gmail.com')

      assert !outcome.success
      assert 1, outcome.result
      assert :is_short, outcome.errors.symbolic[:bob]
      assert :is_fat, outcome.errors.symbolic[:sally]
    end
  end

  describe 'RawInputsCommand' do
    class RawInputsCommand
      include Chaotic::Command
      filter do
        string :name
      end

      def execute
        raw_inputs
      end
    end

    it 'should return the raw input data' do
      input = { 'name' => 'Hello World', 'other' => 'Foo Bar Baz' }
      assert_equal OpenStruct.new(input), RawInputsCommand.run!(input)
    end
  end
end
