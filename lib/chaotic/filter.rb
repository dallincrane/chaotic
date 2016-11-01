# frozen_string_literal: true
module Chaotic
  class Filter
    def self.inherited(child_class)
      filter_name_match = child_class.name.match(/\AChaotic::Filters::(.*)Filter\z/)
      raise 'filename error in filters folder' unless filter_name_match

      filter_name = filter_name_match[1].underscore
      define_method(filter_name) do |*args, &block|
        args.unshift(nil) if args[0].is_a?(Hash)
        new_filter = child_class.new(*args, &block)
        sub_filters.push(new_filter)
      end
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
      @options ||= self.class::DEFAULT_OPTIONS.merge(@given_options)
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
      options[:required] == false ? false : true
    end

    def optional?
      !required?
    end

    def default?
      options.key?(:default)
    end

    def default
      options[:default]
    end

    def discardable?(sub_error, given_filter)
      return true if given_filter.discard_invalid?
      return true if given_filter.discard_empty? && sub_error == :empty
      return true if given_filter.discard_nils? && sub_error == :nil

      false
    end

    def discard_nils?
      options[:discard_nils]
    end

    def discard_empty?
      options[:discard_empty]
    end

    def discard_invalid?
      options[:discard_invalid]
    end
  end
end
