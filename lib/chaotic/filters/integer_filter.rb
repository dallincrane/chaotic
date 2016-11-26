# frozen_string_literal: true
module Chaotic
  module Filters
    class IntegerFilter < Chaotic::Filter
      default_options(
        empty_is_nil: false,
        nils: false,
        delimiter: ', ',
        decimal_mark: '.',
        min: nil,
        max: nil,
        scale: nil,
        in: nil
      )

      def feed(given)
        flipped = flip(given)
        coerced = coerce(flipped)

        error = validate_datum(coerced)
        return [coerced, error] if error

        [coerced, nil]
      end

      private

      def flip(datum)
        return datum unless options.empty_is_nil == true
        datum.try(:empty?) ? nil : datum
      end

      def coerce(datum)
        return datum if datum.blank?

        datum_str =
          if datum.is_a?(Float)
            datum.to_s
          elsif datum.is_a?(BigDecimal)
            datum.to_s('F')
          elsif datum.is_a?(String)
            datum
          end

        return datum unless datum_str

        clean_str = datum_str.tr(options.delimiter, '').tr(options.decimal_mark, '.')
        return datum unless clean_str =~ /\A[-+]?\d*\.?0*\z/
        clean_str.to_i
      end

      def validate_datum(datum)
        return options.nils ? nil : :nils if datum.nil?
        return :integer unless datum.is_a?(Integer)
        return :in unless included?(datum)
        return :min unless above_min?(datum)
        return :max unless below_max?(datum)
        return :scale unless within_scale?(datum)
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
