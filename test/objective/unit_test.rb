# frozen_string_literal: true

require 'test_helper'

class SimpleUnit
  include Objective::Unit

  filter do
    string :name, max: 10
    string :email
    integer :amount, nils: allow
  end

  def validate
    return if email.include?('@')
    add_error(:email, :invalid, 'Email must contain @')
  end
end

describe 'Objective::Unit' do
  describe 'SimpleUnit' do
    it 'should allow valid input' do
      outcome = SimpleUnit.run(name: 'John', email: 'john@gmail.com', amount: 5)

      assert outcome.success
      assert_equal({ name: 'John', email: 'john@gmail.com', amount: 5 }, outcome.inputs)
      assert_nil outcome.errors
    end

    it 'should filter out extra inputs' do
      outcome = SimpleUnit.run(name: 'John', email: 'john@gmail.com', amount: 5, buggers: true)

      assert outcome.success
      assert_equal({ name: 'John', email: 'john@gmail.com', amount: 5 }, outcome.inputs)
      assert_nil outcome.errors
    end

    it 'should discover errors in inputs' do
      outcome = SimpleUnit.run(name: 'JohnTooLong', email: 'john@gmail.com')

      assert !outcome.success
      assert_equal :max, outcome.errors.codes[:name]
    end

    it 'shouldn\'t throw an exception with run!' do
      result = SimpleUnit.run!(name: 'John', email: 'john@gmail.com', amount: 5)
      assert_nil result
    end

    it 'should throw an exception with run!' do
      assert_raises Objective::ValidationError do
        SimpleUnit.run!(name: 'John', email: 'john@gmail.com', amount: 'bob')
      end
    end

    it 'should do standalone validation' do
      outcome = SimpleUnit.run(name: 'JohnLong', email: 'john@gmail.com')
      assert outcome.success
      assert_nil outcome.errors

      outcome = SimpleUnit.run(name: 'JohnTooLong', email: 'john@gmail.com')
      assert !outcome.success
      assert_nil outcome.result
      assert_equal :max, outcome.errors.codes[:name]
    end

    it 'should execute a custom validate method' do
      outcome = SimpleUnit.run(name: 'JohnLong', email: 'xxxx')

      assert !outcome.success
      assert_equal :invalid, outcome.errors.codes[:email]
    end

    it 'should execute custom validate method during run' do
      outcome = SimpleUnit.run(name: 'JohnLong', email: 'xxxx')

      assert !outcome.success
      assert_nil outcome.result
      assert_equal :invalid, outcome.errors.codes[:email]
    end

    it 'should execute custom validate method only if regular validations succeed' do
      outcome = SimpleUnit.run(name: 'JohnTooLong', email: 'xxxx')

      assert !outcome.success
      assert_equal :max, outcome.errors.codes[:name]
      assert_nil outcome.errors.codes[:email]
    end

    it 'should merge multiple hashes' do
      outcome = SimpleUnit.run({ name: 'John', email: 'john@gmail.com' }, email: 'bob@jones.com', amount: 5)

      assert outcome.success
      assert_equal({ name: 'John', email: 'bob@jones.com', amount: 5 }, outcome.inputs)
    end

    it 'shouldn\'t accept non-hashes' do
      assert_raises ArgumentError do
        SimpleUnit.run(nil)
      end

      assert_raises ArgumentError do
        SimpleUnit.run(1)
      end

      assert_raises ArgumentError do
        SimpleUnit.run({ name: 'John' }, 1)
      end
    end

    it 'should accept nothing at all' do
      SimpleUnit.run # make sure nothing is raised
    end

    it 'should return the filtered inputs in the outcome' do
      outcome = SimpleUnit.run(name: ' John ', email: 'john@gmail.com', amount: '5')
      assert_equal({ name: 'John', email: 'john@gmail.com', amount: 5 }, outcome.inputs)
    end
  end

  describe 'DefaultUnit' do
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
      assert_equal({ name: 'Fred' }, outcome.result)
    end

    it 'should use a nils option default value if no value is passed' do
      outcome = DefaultUnit.run
      assert_equal({ name: '-nils-' }, outcome.result)
      assert_equal true, outcome.success
    end

    it 'should use a nils option default value if nil is passed' do
      outcome = DefaultUnit.run(name: nil)
      assert_equal({ name: '-nils-' }, outcome.result)
      assert_equal true, outcome.success
    end

    it 'should use the invalid option default if an invalid value is passed' do
      outcome = DefaultUnit.run(name: /regex/)
      assert_equal({ name: '-invalid-' }, outcome.result)
      assert_equal true, outcome.success
    end

    it 'should use the empty option default if an empty value is passed' do
      outcome = DefaultUnit.run(name: ' ')
      assert_equal({ name: '-empty-' }, outcome.result)
      assert_equal true, outcome.success
    end
  end

  describe 'EigenUnit' do
    class EigenUnit
      include Objective::Unit

      filter do
        string :name
        string :email, nils: allow
      end

      def execute
        { name: name, email: email }
      end
    end

    it 'should define methods for input keys' do
      outcome = EigenUnit.run(name: 'John', email: 'john@gmail.com')
      assert_equal({ name: 'John', email: 'john@gmail.com' }, outcome.result)
    end
  end

  describe 'MutatatedUnit' do
    class MutatatedUnit
      include Objective::Unit

      filter do
        string :name
        string :email, nils: allow
      end

      def execute
        inputs[:name] = 'bob'
        inputs[:email] = 'bob@jones.com'
        { name: inputs[:name], email: inputs[:email] }
      end
    end

    it 'should allow inputs to be changed' do
      outcome = MutatatedUnit.run(name: 'John', email: 'john@gmail.com')
      assert_equal({ name: 'bob', email: 'bob@jones.com' }, outcome.result)
    end
  end

  describe 'ErrorfulUnit' do
    class ErrorfulUnit
      include Objective::Unit

      filter do
        string :name
        string :email, nils: allow
      end

      def execute
        add_error('bob', :is_a_bob)
        1
      end
    end

    it 'should let you add errors' do
      outcome = ErrorfulUnit.run(name: 'John', email: 'john@gmail.com')

      assert !outcome.success
      assert 1, outcome.result
      assert :is_a_bob, outcome.errors.codes[:bob]
    end
  end

  describe 'NestingErrorfulUnit' do
    class NestingErrorfulUnit
      include Objective::Unit

      filter do
        string :name
        string :email, nils: allow
      end

      def execute
        add_error([:people, 'bob'], :is_a_bob)
        1
      end
    end

    it 'should let you add errors nested under a namespace' do
      outcome = NestingErrorfulUnit.run(name: 'John', email: 'john@gmail.com')

      assert !outcome.success
      assert 1, outcome.result
      assert :is_a_bob, outcome.errors[:people].codes['bob']
    end
  end

  describe 'MultiErrorUnit' do
    class MultiErrorUnit
      include Objective::Unit

      filter do
        string :name
        string :email, nils: allow
      end

      def execute
        moar_errors = Objective::Errors::ErrorHash.new
        moar_errors[:bob] = Objective::Errors::ErrorAtom.new(:bob, :is_short)
        moar_errors[:sally] = Objective::Errors::ErrorAtom.new(:sally, :is_fat)

        merge_errors(moar_errors)
        1
      end
    end

    it 'should let you merge errors' do
      outcome = ErrorfulUnit.run(name: 'John', email: 'john@gmail.com')

      assert !outcome.success
      assert 1, outcome.result
      assert :is_short, outcome.errors.codes[:bob]
      assert :is_fat, outcome.errors.codes[:sally]
    end
  end

  describe 'RawInputsUnit' do
    class RawInputsUnit
      include Objective::Unit

      filter do
        string :name
      end

      def execute
        raw_inputs
      end
    end

    it 'should return the raw input data' do
      input = { name: 'Hello World', other: 'Foo Bar Baz' }
      assert_equal OpenStruct.new(input), RawInputsUnit.run!(input)
    end
  end

  # NOTE: this is particularly relevant for unit inheritance and unit mixins
  describe 'multiple filter calls' do
    class MultiFilter
      include Objective::Unit

      filter do
        string :name, max: 10
        integer :age, min: 18, nils: allow
        string :friend, nils: allow
        hash :pets, nils: allow do
          string :cat
        end
      end

      filter do
        string :email
        integer :age, min: 13
        integer :friend, nils: allow
        hash :pets, nils: allow do
          string :dog
        end
      end
    end

    it 'should merge top level filters' do
      outcome = MultiFilter.run(name: 'jerry', email: 'jerry@sanchez.com', age: 42)
      assert outcome.success
      assert_equal({ name: 'jerry', email: 'jerry@sanchez.com', age: 42, friend: nil, pets: nil }, outcome.inputs)
    end

    it 'should not merge top level filter options' do
      outcome = MultiFilter.run(name: 'butterbot', email: 'butterbot@sanchez.com', age: nil)
      assert_equal false, outcome.success
      assert_equal :nils, outcome.errors[:age].codes
    end

    it 'should overwrite top level filter options' do
      outcome = MultiFilter.run(name: 'morty', email: 'morty@sanchez.com', age: 14)
      assert outcome.success
      assert_equal({ name: 'morty', email: 'morty@sanchez.com', age: 14, friend: nil, pets: nil }, outcome.inputs)
    end

    it 'should overwrite top level filter types' do
      outcome = MultiFilter.run(name: 'morty', email: 'morty@sanchez.com', age: 14, friend: 0)
      assert outcome.success
      assert_equal({ name: 'morty', email: 'morty@sanchez.com', age: 14, friend: 0, pets: nil }, outcome.inputs)
    end

    it 'should not merge nested filters' do
      outcome = MultiFilter.run(
        name: 'jerry',
        email: 'jerry@sanchez.com',
        age: 42,
        pets: { dog: 'Snuffles', cat: 'none' }
      )

      expected_inputs = {
        name: 'jerry',
        email: 'jerry@sanchez.com',
        age: 42,
        friend: nil,
        pets: { dog: 'Snuffles' }
      }

      assert outcome.success
      assert_equal expected_inputs, outcome.inputs
    end
  end

  describe 'inherited unit' do
    class SimpleInheritedUnit < SimpleUnit
      filter do
        integer :age
      end
    end

    it 'should filter with inherited unit' do
      outcome = SimpleInheritedUnit.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
      assert outcome.success
      assert_equal({ name: 'bob', email: 'jon@jones.com', age: 10, amount: 22 }, outcome.inputs)
    end

    it 'should filter with original unit' do
      outcome = SimpleUnit.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
      assert outcome.success
      assert_equal({ name: 'bob', email: 'jon@jones.com', amount: 22 }, outcome.inputs)
    end

    it 'shouldnt collide' do
      outcome = SimpleInheritedUnit.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
      assert outcome.success
      assert_equal({ name: 'bob', email: 'jon@jones.com', age: 10, amount: 22 }, outcome.inputs)

      outcome = SimpleUnit.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
      assert outcome.success
      assert_equal({ name: 'bob', email: 'jon@jones.com', amount: 22 }, outcome.inputs)
    end
  end

  describe 'mixin unit' do
    module UnitModule
      def self.included(base)
        base.class_eval do
          include Objective::Unit
          filter do
            string :name, max: 10
            string :email
            integer :amount, nils: allow
          end
        end
      end

      def validate
        return if email.include?('@')
        add_error(:email, :invalid, 'Email must contain @')
      end
    end

    class SecondHandUnit
      include UnitModule

      filter do
        integer :age
      end

      def execute
        'szechuan sauce'
      end
    end

    it 'should filter with included filter' do
      outcome = SecondHandUnit.run(name: 'bob', email: 'jon@jones.com', age: 10)
      assert outcome.success
      assert_equal({ name: 'bob', email: 'jon@jones.com', age: 10, amount: nil }, outcome.inputs)
      assert_equal 'szechuan sauce', outcome.result
    end

    it 'should run with included validation' do
      outcome = SecondHandUnit.run(name: 'bob', email: 'woops', age: 10)
      assert_equal false, outcome.success
      assert_equal :invalid, outcome.errors[:email].codes
    end
  end

  describe 'mixin filter' do
    # NOTE: Previously, ALLOW and DENY constants were set to any class that included Objective::Unit.
    #       This describes a scenario where those constants would cause an error
    describe 'UnitIncludeModuleFilter' do
      module NonUnitWithFilter
        def self.included(base)
          base.filter do
            string :name, max: 10
            string :email
            integer :amount, nils: allow
          end
        end

        def validate
          return if email.include?('@')
          add_error(:email, :invalid, 'Email must contain @')
        end
      end

      class UnitIncludeModuleFilter
        include Objective::Unit
        include NonUnitWithFilter

        filter do
          integer :age
        end

        def execute
          'szechuan sauce'
        end
      end

      it 'should filter with included filter' do
        outcome = UnitIncludeModuleFilter.run(name: 'bob', email: 'jon@jones.com', age: 10, amount: 22)
        assert outcome.success
        assert_equal({ name: 'bob', email: 'jon@jones.com', age: 10, amount: 22 }, outcome.inputs)
        assert_equal 'szechuan sauce', outcome.result
      end
    end
  end
end
