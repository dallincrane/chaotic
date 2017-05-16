# frozen_string_literal: true
module Chaotic
  module Filters
    class StringFilter < Chaotic::Filter
      default_options(
        nils: false,
        allow_control_characters: false,
        strip: true,
        empty: false,
        min: nil,
        max: nil,
        in: nil,
        matches: nil,
        decimal_format: 'F'
      )

      def coerce(raw)
        return raw unless raw.is_a?(String) || coercable?(raw)
        tmp = raw.is_a?(BigDecimal) ? raw.to_s(options.decimal_format) : raw.to_s
        tmp = tmp.gsub(/[^[:print:]\t\r\n]+/, ' ') unless options.allow_control_characters
        tmp = tmp.strip if options.strip
        tmp
      end

      def coercable?(raw)
        Chaotic.coerce_to_string.map { |klass| raw.is_a?(klass) }.any?
      end

      def coerce_error(coerced)
        return :string unless coerced.is_a?(String)
      end

      def validate(coerced)
        return :empty if !options.empty && coerced.empty?
        return :min if options.min && coerced.length < options.min
        return :max if options.max && coerced.length > options.max
        return :in if options.in && !options.in.include?(coerced)
        return :matches if options.matches && (options.matches !~ coerced)
      end
    end
  end
end
