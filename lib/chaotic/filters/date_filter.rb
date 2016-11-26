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

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)
        return [given, :date] unless coerced.is_a?(Date)

        error = validate_datum(coerced)
        return [coerced, error] if error

        [coerced, nil]
      end

      private

      def coerce(given)
        return given if given.is_a?(Date) # Date and DateTime
        return given.to_date if given.respond_to?(:to_date)
        parse(given) if given.is_a?(String)
      end

      def parse(data)
        options.format ? Date.strptime(data, options.format) : Date.parse(data)
      rescue ArgumentError
        nil
      end

      def validate_datum(coerced)
        return :after if options.after && coerced <= options.after
        return :before if options.before && coerced >= options.before
      end
    end
  end
end
