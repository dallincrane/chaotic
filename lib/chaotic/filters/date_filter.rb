# frozen_string_literal: true
module Chaotic
  module Filters
    class DateFilter < Chaotic::Filter
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
        return :after if options.after && coerced <= options.after
        return :before if options.before && coerced >= options.before
      end
    end
  end
end
