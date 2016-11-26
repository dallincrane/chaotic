# frozen_string_literal: true
module Chaotic
  module Filters
    class StringFilter < Chaotic::Filter
      default_options(
        nils: false,
        strict: false,
        allow_control_characters: false,
        strip: true,
        empty: false,
        min_length: nil,
        max_length: nil,
        in: nil,
        matches: nil
      )

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)
        return [given, :string] unless coerced.is_a?(String)

        coerced = strip_chars(coerced)
        return handle_empty(coerced) if coerced.empty?

        error = validate_datum(coerced)
        return [coerced, error] if error

        [coerced, nil]
      end

      def coerce(given)
        return given if options.strict
        return given if given.is_a?(String)
        given.to_s if Chaotic.coerce_to_string.map { |klass| given.is_a?(klass) }.any?
      end

      def strip_chars(coerced)
        result = coerced
        result = result.gsub(/[^[:print:]\t\r\n]+/, ' ') unless options.allow_control_characters
        result = result.strip if options.strip
        result
      end

      def validate_datum(coerced)
        return :min_length if options.min_length && coerced.length < options.min_length
        return :max_length if options.max_length && coerced.length > options.max_length
        return :in if options.in && !options.in.include?(coerced)
        return :matches if options.matches && (options.matches !~ coerced)
      end
    end
  end
end
