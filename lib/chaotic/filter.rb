# frozen_string_literal: true
module Chaotic
  class Filter
    Options = OpenStruct.new

    def self.config
      yield Options
    end

    def self.inherited(child_class)
      method_name = filter_name(child_class)

      define_method(method_name) do |*args, &block|
        args.unshift(key) if args[0].is_a?(Hash)
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
    attr_reader :sub_filters

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
      sub_filters.each_with_object({}) { |sf, result| result[sf.key] = sf }
    end

    def dup
      dupped = self.class.new
      sub_filters.each { |sf| dupped.sub_filters.push(sf) }
      dupped
    end

    def required?
      !optional?
    end

    def optional?
      options.discard_nils || options.discard_empty || options.discard_invalid
    end

    def default?
      options.respond_to?(:default)
    end

    def default
      options.default
    end

    def discardable?(sub_error)
      options.discard_invalid == true ||
        (options.discard_empty == true && sub_error == :empty) ||
        (options.discard_nils == true && sub_error == :nil)
    end

    def feed(raw)
      errors = :nils if raw.nil? && !options.nils
      return feed_result(errors, raw) if raw.nil?

      coerced = options.strict ? raw : coerce(raw)
      errors = coerce_error(coerced)
      return feed_result(errors, raw, coerced) if errors

      errors = validate(coerced)
      feed_result(errors, raw, coerced)
    end

    def feed_result(errors, raw, coerced = nil)
      OpenStruct.new(
        raw: raw,
        coerced: coerced.nil? ? raw : coerced,
        inputs: coerced.nil? ? raw : coerced,
        errors: errors
      )
    end

    def coerce(raw)
      raw
    end

    def coerce_error(coerced)
    end

    def validate(coerced)
    end
  end
end
