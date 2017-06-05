# frozen_string_literal: true

module Objective
  module Filters
    class SymbolFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        empty: Objective::DENY,
        strict: false,
        in: nil
      )

      def coerce(raw)
        if raw.is_a?(String)
          raw = raw.strip
          return raw if raw.empty?
        end

        return raw unless raw.respond_to?(:to_sym)
        raw.to_sym
      end

      def coerce_error(coerced)
        return :empty if coerced == '' && options.empty != Objective::ALLOW
        return :symbol unless coerced.is_a?(Symbol)
      end

      def validate(coerced)
        return :in if options.in && !options.in.include?(coerced)
      end
    end
  end
end
