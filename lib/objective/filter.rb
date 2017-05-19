# frozen_string_literal: true
module Objective
  class Filter
    def self.inherited(child_class)
      method_name = filter_name(child_class)

      define_method(method_name) do |*args, &block|
        args.unshift(nil) if args[0].is_a?(Hash)
        new_filter = child_class.new(*args, &block)
        sub_filters.push(new_filter)
      end
    end

    def self.filter_name(klass = self)
      filter_name = klass.name.match(/\AObjective::Filters::(.*)Filter\z/)&.[](1)&.underscore
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
      Objective::Filters::Config[self.class.filter_name].to_h
    end

    def sub_filters_hash
      sub_filters.each_with_object({}) { |sf, result| result[sf.key] = sf }
    end

    def dup
      dupped = self.class.new
      sub_filters.each { |sf| dupped.sub_filters.push(sf) }
      dupped
    end

    def default?
      options.to_h.key?(:default)
    end

    def default
      options.default
    end

    def feed(raw)
      return feed_none if raw == Objective::NONE
      return feed_nil if raw.nil?

      coerced = options.strict == true ? raw : coerce(raw)
      errors = coerce_error(coerced)
      return feed_invalid(errors, raw, raw) if errors

      errors = validate(coerced)
      return feed_empty(raw, coerced) if errors == :empty

      feed_result(errors, raw, coerced)
    end

    def feed_none
      case options.none
      when Objective::ALLOW
        return Objective::DISCARD
      when Objective::DENY
        coerced = Objective::NONE
        errors = :required
      when Objective::DISCARD
        raise 'the none option cannot be discarded — did you mean to use allow instead?'
      else
        coerced = options.none
      end

      feed_result(errors, Objective::NONE, coerced)
    end

    def feed_nil
      case options.nils
      when Objective::ALLOW
        coerced = nil
        errors = nil
      when Objective::DENY
        coerced = nil
        errors = :nils
      when Objective::DISCARD
        return Objective::DISCARD
      else
        coerced = options.nils
      end

      feed_result(errors, nil, coerced)
    end

    def feed_invalid(errors, raw, coerced)
      case options.invalid
      when Objective::DENY
        # nothing
      when Objective::DISCARD
        return Objective::DISCARD
      else
        coerced = options.invalid
      end

      feed_result(errors, raw, coerced)
    end

    def feed_empty(raw, coerced)
      case options.empty
      when Objective::ALLOW
        errors = nil
      when Objective::DENY
        errors = :empty
      when Objective::DISCARD
        return Objective::DISCARD
      else
        coerced = options.empty
      end

      feed_result(errors, raw, coerced)
    end

    def feed_result(errors, raw, coerced)
      OpenStruct.new(
        errors: errors,
        raw: raw,
        coerced: coerced,
        inputs: coerced
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
      when Objective::Errors::ErrorHash
        given_error
      when Objective::Errors::ErrorArray
        given_error
      when Objective::Errors::ErrorAtom
        given_error
      else
        Objective::Errors::ErrorAtom.new(key, given_error)
      end
    end
  end
end
