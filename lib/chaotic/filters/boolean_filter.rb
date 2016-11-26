# frozen_string_literal: true
module Chaotic
  module Filters
    class BooleanFilter < Chaotic::Filter
      default_options(
        nils: false
      )

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)
        return [given, :boolean] unless boolean?(coerced)

        [coerced, nil]
      end

      def coerce(given)
        return given if options.strict
        return given if boolean?(given)
        Chaotic.boolean_map[given.to_s.downcase] if given.respond_to?(:to_s)
      end

      def boolean?(datum)
        datum == true || datum == false
      end
    end
  end
end
