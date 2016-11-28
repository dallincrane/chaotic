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

      def coerce(raw)
        return raw if options.strict
        return raw unless raw.is_a?(String) || coercable?(raw)
        tmp = raw.to_s
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
        return :min_length if options.min_length && coerced.length < options.min_length
        return :max_length if options.max_length && coerced.length > options.max_length
        return :in if options.in && !options.in.include?(coerced)
        return :matches if options.matches && (options.matches !~ coerced)
      end
    end
  end
end
