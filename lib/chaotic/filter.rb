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
      options.to_h.key?(:default)
    end

    def default
      options.default
    end

    def discardable?(sub_error)
      options.discard_invalid == true ||
        (options.discard_nils == true && sub_error == :required) ||
        (options.discard_nils == true && sub_error == :nils) ||
        (options.discard_empty == true && sub_error == :empty)
    end

    def feed(raw)
      errors = :required if raw == Chaotic::NONE
      return feed_result(errors, raw, raw) if raw == Chaotic::NONE

      errors = :nils if raw.nil? && options.nils != true
      return feed_result(errors, raw, raw) if raw.nil?

      coerced = options.strict == true ? raw : coerce(raw)
      errors = coerce_error(coerced)
      return feed_result(errors, raw, coerced) if errors

      errors = validate(coerced)
      feed_result(errors, raw, coerced)
    end

    def feed_result(errors, raw, coerced)
      return Chaotic::DISCARD if errors && discardable?(errors) && !default?

      if coerced == Chaotic::NONE && default?
        errors = nil
        coerced = default
      end

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

    def handle_errors(given_error)
      return if given_error.nil?

      case given_error
      when Chaotic::Errors::ErrorHash
        given_error
      when Chaotic::Errors::ErrorArray
        given_error
      when Chaotic::Errors::ErrorAtom
        given_error
      else
        Chaotic::Errors::ErrorAtom.new(key, given_error)
      end
    end
  end
end
