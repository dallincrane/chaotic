# frozen_string_literal: true
module Chaotic
  module Filters
    class BooleanFilter < Chaotic::Filter
      default_options(
        nils: false
      )

      private

      def coerce(raw)
        return raw if options.strict
        return raw if boolean?(raw)
        Chaotic.boolean_map[raw.to_s.downcase] if raw.respond_to?(:to_s)
      end

      def coerce_error(coerced)
        return :boolean unless boolean?(coerced)
      end

      def boolean?(datum)
        datum == true || datum == false
      end
    end
  end
end
