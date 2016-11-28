# frozen_string_literal: true
module Chaotic
  module Filters
    class DateFilter < Chaotic::Filter
      default_options(
        nils: false,
        format: nil, # If nil, Date.parse will be used for coercion. If something like "%Y-%m-%d", Date.strptime is used
        after: nil,  # A date object, representing the minimum date allowed, inclusive
        before: nil  # A date object, representing the maximum date allowed, inclusive
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

      def validate(input)
        return :after if options.after && input <= options.after
        return :before if options.before && input >= options.before
      end
    end
  end
end
