# frozen_string_literal: true
module Chaotic
  module Filters
    class FloatFilter < Chaotic::Filter
      default_options(
        nils: false,
        delimiter: ', ',
        decimal_mark: '.',
        min: nil,
        max: nil,
        scale: nil
      )

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)

        error = validate_datum(coerced)
        return [coerced, error] if error

        [coerced, nil]
      end

      private

      def coerce(datum)
        return datum if datum.blank?

        return datum.to_f if datum.is_a?(Integer) || datum.is_a?(BigDecimal)

        return datum unless datum.is_a?(String)

        clean_str = datum.tr(options.delimiter, '').tr(options.decimal_mark, '.')
        return datum unless clean_str =~ /\A[-+]?\d*\.?\d*\z/
        clean_str.to_f
      end

      def validate_datum(datum)
        return options.nils ? nil : :nils if datum.nil?
        return :float unless datum.is_a?(Float)
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
