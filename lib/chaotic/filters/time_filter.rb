# frozen_string_literal: true
module Chaotic
  module Filters
    class TimeFilter < Chaotic::Filter
      default_options(
        nils: false,
        format: nil,
        after: nil,
        before: nil
      )

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)
        return [given, :time] unless coerced.is_a?(Time)

        error = validate(coerced)
        return [coerced, error] if error

        [coerced, nil]
      end

      private

      def coerce(given)
        return given if given.is_a?(Time)
        return given.to_time if given.respond_to?(:to_time)
        parse(given) if given.is_a?(String)
      end

      def parse(given)
        options.format ? Time.strptime(given, options.format) : Time.parse(given)
      rescue ArgumentError
        nil
      end

      def validate(coerced)
        return :after if options.after && coerced <= options.after
        return :before if options.before && coerced >= options.before
      end
    end
  end
end
