# frozen_string_literal: true

module Objective
  module Unit
    extend ActiveSupport::Concern

    included do
      attr_reader :inputs, :raw_inputs, :built
      const_set('ALLOW', Objective::ALLOW)
      const_set('DENY', Objective::DENY)
      const_set('DISCARD', Objective::DISCARD)
    end

    class_methods do
      def filter(&block)
        root_filter.filter(&block)
        root_filter.keys.each do |key|
          define_method(key) { inputs[key] }
        end
      end

      def root_filter
        @root_filter ||=
          superclass.try(:root_filter).try(:dup) ||
          Objective::Filters::RootFilter.new
      end

      def build(*args)
        new.build(*args)
      end

      def build!(*args)
        outcome = build(*args)
        return outcome.result if outcome.success
        raise Objective::ValidationError, outcome.errors
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

    def build(*args)
      filter_result = self.class.root_filter.feed(*args)
      @raw_inputs = filter_result.coerced
      @inputs = filter_result.inputs
      @errors = filter_result.errors
      @built = true
      try('validate') if valid?
      outcome
    end

    def run(*args)
      build(*args) unless built
      result = valid? ? try('execute') : nil
      outcome(result)
    end

    def valid?
      @errors.nil?
    end

    def outcome(result = nil)
      Objective::Outcome.new(
        success: valid?,
        result: result,
        errors: @errors,
        inputs: inputs
      )
    end

    protected

    def add_error(key, kind, message = nil)
      raise(ArgumentError, 'Invalid kind') unless kind.is_a?(Symbol)

      @errors ||= Objective::Errors::ErrorHash.new
      @errors.tap do |root_error_hash|
        path = key.to_s.split('.')
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
