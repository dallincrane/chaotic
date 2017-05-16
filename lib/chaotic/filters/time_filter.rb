# frozen_string_literal: true
module Chaotic
  module Filters
    class TimeFilter < Chaotic::Filter
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
        return :after if options.after && coerced <= options.after
        return :before if options.before && coerced >= options.before
      end
    end
  end
end
