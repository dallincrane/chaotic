# frozen_string_literal: true
module Chaotic
  class Filter
    Result = Struct.new(:result_data, :error_symbol, :raw_data)
    Options = OpenStruct.new

    def self.config
      yield Options
    end

    def self.inherited(child_class)
      method_name = filter_name(child_class)

      define_method(method_name) do |*args, &block|
        args.unshift(nil) if args[0].is_a?(Hash)
        new_filter = child_class.new(*args, &block)
        sub_filters.push(new_filter)
      end
    end

    def self.default_options(given)
      child_class_options = Options[filter_name] ||= OpenStruct.new
      given.each_pair { |key, value| child_class_options[key] = value }
    end

    def self.filter_name(klass = self)
      filter_name = klass.name.match(/\AChaotic::Filters::(.*)Filter\z/)&.[](1)&.underscore
      raise 'filename error in filters folder' unless filter_name
      filter_name
    end

    attr_reader :key
    attr_accessor :sub_filters

    def initialize(key = nil, opts = {}, &block)
      @key = key
      @given_options = opts
      @sub_filters ||= []

      instance_eval(&block) if block_given?
    end

    def options
      @options ||= OpenStruct.new(type_specific_options_hash.merge(@given_options))
    end

    def type_specific_options_hash
      Options[self.class.filter_name].to_h
    end

    def sub_filters_hash
      sub_filters.each_with_object({}) { |filter, result| result[filter.key] = filter }
    end

    # TODO: make this go deeper than one level
    def dup
      dupped = self.class.new
      sub_filters.each { |filter| dupped.sub_filters.push(filter) }
      dupped
    end

    def required?
      !optional?
    end

    def optional?
      options.required == false
    end

    def default?
      options.respond_to?(:default)
    end

    def default
      options.default
    end

    def discardable?(sub_error)
      return true if options.discard_invalid
      return true if options.discard_empty && sub_error == :empty
      return true if options.discard_nils && sub_error == :nil

      false
    end
  end
end
