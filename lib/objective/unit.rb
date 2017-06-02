# frozen_string_literal: true

module Objective
  module Unit
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        attr_reader :inputs, :raw_inputs
        const_set('ALLOW', Objective::ALLOW)
        const_set('DENY', Objective::DENY)
      end
    end

    module ClassMethods
      def filter(&block)
        root_filter.filter(&block)
        root_filter.keys.each do |key|
          define_method(key) { inputs[key] }
        end
      end

      def root_filter
        @root_filter ||=
          if superclass.respond_to?(:root_filter)
            superclass.root_filter.dup
          else
            Objective::Filters::RootFilter.new
          end
      end

      def run(*args)
        new.run(*args)
      end

      def run!(*args)
        outcome = run(*args)
        return outcome.result if outcome.success
        raise Objective::ValidationError, outcome.errors
      end
    end

    # INSTANCE METHODS

    def run(*args)
      filter_result = self.class.root_filter.feed(*args)
      @raw_inputs = filter_result.coerced
      @inputs = filter_result.inputs
      @errors = filter_result.errors
      validate if respond_to?(:validate) && valid?
      result = valid? && respond_to?(:execute) ? execute : nil

      Objective::Outcome.new(
        success: valid?,
        result: result,
        errors: @errors,
        inputs: inputs
      )
    end

    def valid?
      @errors.nil?
    end

    protected

    def add_error(key, kind, message = nil)
      raise(ArgumentError, 'Invalid kind') unless kind.is_a?(Symbol)

      @errors ||= Objective::Errors::ErrorHash.new
      @errors.tap do |root_error_hash|
        path = Objective::Helpers.wrap(key)
        last = path.pop

        inner = path.inject(root_error_hash) do |current_error_hash, path_key|
          current_error_hash[path_key] ||= Objective::Errors::ErrorHash.new
        end

        inner[last] = Objective::Errors::ErrorAtom.new(key, kind, message: message)
      end
    end

    def merge_errors(hash)
      return unless hash.any?
      @errors ||= Objective::Errors::ErrorHash.new
      @errors.merge!(hash)
    end
  end
end
