# frozen_string_literal: true
module Chaotic
  module Command
    extend ActiveSupport::Concern

    class_methods do
      def params(&block)
        root_filter.params(&block)
        root_filter.keys.each do |key|
          define_method(key) { @inputs[key] }
          define_method("#{key}=") { |v| @inputs[key] = v }
        end
      end

      def build(*args)
        new(*args).chaotic_outcome('itself')
      end

      def build!(*args)
        instance_outcome = run(*args)
        return instance_outcome.result if instance_outcome.success?
        raise Errors::ValidationException, instance_outcome.errors
      end

      def run(*args)
        new(*args).chaotic_outcome('execute')
      end

      def run!(*args)
        instance_outcome = run(*args)
        return instance_outcome.result if instance_outcome.success?
        raise Errors::ValidationException, instance_outcome.errors
      end

      def root_filter
        @root_filter ||= superclass.try(:root_filter).try(:dup) || HashFilter.new
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

      Outcome.new(
        success: valid?,
        result: valid? ? send(command) : nil,
        errors: @errors,
        inputs: @inputs
      )
    end

    protected

    attr_reader :inputs, :raw_inputs

    # add_error("name", :too_short)
    # add_error("colors.foreground", :not_a_color) # => to create errors = {colors: {foreground: :not_a_color}}
    # or, supply a custom message:
    # add_error("name", :too_short, "The name 'blahblahblah' is too short!")
    def add_error(key, kind, message = nil)
      raise(ArgumentError, 'Invalid kind') unless kind.is_a?(Symbol)

      @errors ||= ErrorHash.new
      @errors.tap do |root_error_hash|
        path = key.to_s.split('.')
        last = path.pop

        inner = path.inject(root_error_hash) do |current_error_hash, path_key|
          current_error_hash[path_key] ||= ErrorHash.new
        end

        inner[last] = ErrorAtom.new(key, kind, message: message)
      end
    end

    def merge_errors(hash)
      return unless hash.any?
      @errors ||= ErrorHash.new
      @errors.merge!(hash)
    end
  end
end
