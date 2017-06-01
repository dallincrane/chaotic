# frozen_string_literal: true

module Objective
  module Filters
    class DateFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
        format: nil,
        min: nil,
        max: nil
      )

      private

      def coerce(raw)
        return raw if raw.is_a?(Date) # Date and DateTime
        return raw.to_date if raw.respond_to?(:to_date)
        parse(raw) if raw.is_a?(String)
      end

      def parse(data)
        options.format ? Date.strptime(data, options.format) : Date.parse(data)
      rescue ArgumentError
        nil
      end

      def coerce_error(coerced)
        return :date unless coerced.is_a?(Date)
      end

      def validate(coerced)
        return :min if options.min && coerced <= options.min
        return :max if options.max && coerced >= options.max
      end
    end
  end
end
