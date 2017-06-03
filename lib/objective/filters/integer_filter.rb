# frozen_string_literal: true

module Objective
  module Filters
    class IntegerFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
        delimiter: ', ',
        decimal_mark: '.',
        min: nil,
        max: nil,
        in: nil
      )

      private

      def coerce(datum)
        if datum.is_a?(String)
          datum = datum.strip
          return datum if datum.empty?
        end

        datum_str = raw_to_string(datum)
        return datum unless datum_str
        return datum if datum_str.include?('.') && options.decimal_mark != '.' && !options.delimiter.include?('.')

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
    end
  end
end
