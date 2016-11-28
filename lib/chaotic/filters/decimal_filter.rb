# frozen_string_literal: true
module Chaotic
  module Filters
    class DecimalFilter < Chaotic::Filter
      default_options(
        nils: false,
        delimiter: ', ',
        decimal_mark: '.',
        min: nil,
        max: nil,
        scale: nil
      )

      private

      # TODO: the Rational class should be coerced - it requires a precision argument
      def coerce(datum)
        return datum if datum.blank?

        return datum.to_d if datum.is_a?(Integer) || datum.is_a?(Float)

        return datum unless datum.is_a?(String)

        clean_str = datum.tr(options.delimiter, '').tr(options.decimal_mark, '.')
        return datum unless clean_str =~ /\A[-+]?\d*\.?\d*\z/
        clean_str.to_d
      end

      def coerce_error(coerced)
        return :decimal unless coerced.is_a?(BigDecimal)
      end

      def validate(datum)
        return :min unless above_min?(datum)
        return :max unless below_max?(datum)
        return :scale unless within_scale?(datum)
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
