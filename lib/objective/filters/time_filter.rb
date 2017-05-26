# frozen_string_literal: true

module Objective
  module Filters
    class TimeFilter < Objective::Filter
      Options = OpenStruct.new(
        none: Objective::DENY,
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
        format: nil,
        min: nil,
        max: nil
      )

      private

      def coerce(raw)
        return raw if raw.is_a?(Time)
        return parse(raw) if raw.is_a?(String)
        return raw.to_time if raw.respond_to?(:to_time)
        raw
      end

      def parse(raw)
        options.format ? Time.strptime(raw, options.format) : Time.parse(raw)
      rescue ArgumentError
        nil
      end

      def coerce_error(coerced)
        return :time unless coerced.is_a?(Time)
      end

      def validate(coerced)
        return :min if options.min && coerced <= options.min
        return :max if options.max && coerced >= options.max
      end
    end
  end
end
