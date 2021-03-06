# frozen_string_literal: true

module Objective
  class Filter
    def self.inherited(child_class)
      filter_match = child_class.name.match(/\AObjective::Filters::(.*)Filter\z/)
      raise "invalid class name for filter: #{child_class.name}" unless filter_match
      filter_name = filter_match[1].gsub(/(.)([A-Z])/, '\1_\2').downcase

      define_method(filter_name) do |*args, &block|
        args.unshift(nil) if args[0].is_a?(Hash)
        new_filter = child_class.new(*args, &block)
        sub_filters.push(new_filter)
      end
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
      @options ||= OpenStruct.new(self.class.const_get('Options').to_h.merge(@given_options))
    end

    def allow
      Objective::ALLOW
    end

    def deny
      Objective::DENY
    end

    def sub_filters_hash
      sub_filters.each_with_object({}) { |sf, result| result[sf.key] = sf }
    end

    def dup
      dupped = self.class.new
      sub_filters.each { |sf| dupped.sub_filters.push(sf) }
      dupped
    end

    def feed(raw)
      return feed_nil if raw.nil?

      coerced = options.strict == true ? raw : coerce(raw)
      errors = coerce_error(coerced)

      return feed_empty(raw, coerced) if errors == :empty
      return feed_invalid(errors, raw, raw) if errors

      errors = validate(coerced)
      feed_result(errors, raw, coerced)
    end

    def feed_nil
      case options.nils
      when allow
        errors = nil
        coerced = nil
      when deny
        errors = :nils
        coerced = nil
      else
        errors = nil
        coerced = options.nils
      end

      feed_result(errors, nil, coerced)
    end

    def feed_invalid(errors, raw, coerced)
      case options.invalid
      when allow
        errors = nil
      when deny
        nil
      else
        errors = nil
        coerced = options.invalid
      end

      feed_result(errors, raw, coerced)
    end

    def feed_empty(raw, coerced)
      case options.empty
      when allow
        errors = nil
      when deny
        errors = :empty
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
