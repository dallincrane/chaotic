# frozen_string_literal: true
module Chaotic
  module Command
    extend ActiveSupport::Concern

    included do
      attr_reader :inputs, :raw_inputs
    end

    class_methods do
      def params(&block)
        root_filter.params(&block)
        root_filter.keys.each do |key|
          define_method(key) { @inputs[key] }
          define_method("#{key}=") { |v| @inputs[key] = v }
        end
      end

      def root_filter
        @root_filter ||= superclass.try(:root_filter).try(:dup) || Chaotic::Filters::HashFilter.new
      end

      def build(*args)
        new(*args).chaotic_outcome('itself')
      end

      def build!(*args)
        instance_outcome = build(*args)
        return instance_outcome.result if instance_outcome.success?
        raise Chaotic::ValidationError, instance_outcome.errors
      end

      def run(*args)
        new(*args).chaotic_outcome('execute')
      end

      def run!(*args)
        instance_outcome = run(*args)
        return instance_outcome.result if instance_outcome.success?
        raise Chaotic::ValidationError, instance_outcome.errors
      end
    end

    # Instance methods
    def initialize(*args)
      @raw_inputs = args.inject({}.with_indifferent_access) do |h, arg|
        raise(ArgumentError, 'All arguments must be hashes') unless arg.is_a?(Hash)
        h.deep_merge!(arg)
      end

      # Do field-level validation / filtering:
      @inputs, @errors = self.class.root_filter.filter(@raw_inputs)

      # Run a custom validation method if supplied:
      try(:validate) if valid?
    end

    def valid?
      @errors.nil?
    end

    def chaotic_outcome(command)
      unless respond_to?(command)
        raise NoMethodError, "the #{command} method must be defined"
      end

      result = valid? ? send(command) : nil

      Chaotic::Outcome.new(
        success: valid?,
        result: result,
        errors: @errors,
        inputs: @inputs
      )
    end

    protected

    # add_error("name", :too_short)
    # add_error("colors.foreground", :not_a_color) # => to create errors = {colors: {foreground: :not_a_color}}
    # or, supply a custom message:
    # add_error("name", :too_short, "The name 'blahblahblah' is too short!")
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

  class ValidationError < StandardError
    attr_accessor :errors

    def initialize(errors)
      self.errors = errors
    end

    def to_s
      errors.message_list.join('; ').to_s
    end
  end
end
