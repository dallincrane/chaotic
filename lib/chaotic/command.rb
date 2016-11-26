# frozen_string_literal: true
module Chaotic
  module Command
    extend ActiveSupport::Concern

    included do
      attr_reader :inputs, :raw_inputs, :built
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
          Chaotic::Filters::RootFilter.new
      end

      def build(*args)
        new.build(*args)
      end

      def build!(*args)
        outcome = build(*args)
        return outcome.result if outcome.success
        raise Chaotic::ValidationError, outcome.errors
      end

      def run(*args)
        new.run(*args)
      end

      def run!(*args)
        outcome = run(*args)
        return outcome.result if outcome.success
        raise Chaotic::ValidationError, outcome.errors
      end
    end

    # INSTANCE METHODS

    def build(*args)
      filtered = self.class.root_filter.feed(*args)
      @raw_inputs = filtered.coerced
      @inputs = filtered.inputs
      @errors = filtered.errors
      # @inputs, @errors, @raw_inputs = self.class.root_filter.feed(*args).values
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
      Chaotic::Outcome.new(
        success: valid?,
        result: result,
        errors: @errors,
        inputs: inputs
      )
    end

    protected

    def add_error(key, kind, message = nil)
      raise(ArgumentError, 'Invalid kind') unless kind.is_a?(Symbol)

      @errors ||= Chaotic::Errors::ErrorHash.new
      @errors.tap do |root_error_hash|
        path = key.to_s.split('.')
        last = path.pop

        inner = path.inject(root_error_hash) do |current_error_hash, path_key|
          current_error_hash[path_key] ||= Chaotic::Errors::ErrorHash.new
        end

        inner[last] = Chaotic::Errors::ErrorAtom.new(key, kind, message: message)
      end
    end

    def merge_errors(hash)
      return unless hash.any?
      @errors ||= Chaotic::Errors::ErrorHash.new
      @errors.merge!(hash)
    end
  end
end
