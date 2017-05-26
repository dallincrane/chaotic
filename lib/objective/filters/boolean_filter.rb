# frozen_string_literal: true

module Objective
  module Filters
    class BooleanFilter < Objective::Filter
      Options = OpenStruct.new(
        none: Objective::DENY,
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
        coercion_map: {
          'true' => true,
          'false' => false,
          '1' => true,
          '0' => false
        }.freeze
      )

      private

      def coerce(raw)
        return raw if boolean?(raw)
        options.coercion_map[raw.to_s.downcase] if raw.respond_to?(:to_s)
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
