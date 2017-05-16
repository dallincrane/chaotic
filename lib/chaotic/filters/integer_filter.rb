# frozen_string_literal: true
module Chaotic
  module Filters
    class IntegerFilter < Chaotic::Filter
      private

      def coerce(datum)
        return datum if datum.blank?

        datum_str = raw_to_string(datum)
        return datum unless datum_str

        clean_str = datum_str.tr(options.delimiter, '').tr(options.decimal_mark, '.')
        return datum unless clean_str =~ /\A[-+]?\d*\.?0*\z/
        clean_str.to_i
      end

      def raw_to_string(raw)
        if raw.is_a?(Float)
          raw.to_s
        elsif raw.is_a?(BigDecimal)
          raw.to_s('F')
        elsif raw.is_a?(String)
          raw
        end
      end

      def coerce_error(coerced)
        return :integer unless coerced.is_a?(Integer)
      end

      def validate(coerced)
        return :in unless included?(coerced)
        return :min unless above_min?(coerced)
        return :max unless below_max?(coerced)
        return :scale unless within_scale?(coerced)
      end

      def included?(datum)
        return true if options.in.nil?
        options.in.include?(datum)
      end

      def above_min?(datum)
        return true if options.min.nil?
        datum >= options.min
      end

      def below_max?(datum)
        return true if options.max.nil?
        datum <= options.max
      end

      def within_scale?(datum)
        return true if options.scale.nil?
        (datum - datum.round(options.scale)).zero?
      end
    end
  end
end
