# frozen_string_literal: true
module Chaotic
  module Filters
    class ArrayFilter < Chaotic::Filter
      default_options(
        nils: false,
        wrap: false
      )

      def feed(raw)
        result = super(raw)
        return result if result.errors || result.inputs.nil?

        inputs = []
        errors = Chaotic::Errors::ErrorArray.new

        sub_filter = sub_filters.first

        index_shift = 0

        data = result.coerced
        data.each_with_index do |sub_data, index|
          sub_result = sub_filter.feed(sub_data)
          sub_data = sub_result.inputs
          sub_error = sub_result.errors

          if sub_error.nil?
            inputs << sub_data
          elsif sub_filter.discardable?(sub_error)
            if sub_filter.default?
              inputs << sub_filter.default
            else
              index_shift += 1
            end
          else
            errors[index - index_shift] = sub_filter.handle_errors(sub_error)
            inputs << sub_data
          end
        end

        result.inputs = inputs
        result.errors = errors.present? ? errors : nil
        result
      end

      def coerce(raw)
        return Array.wrap(raw) if options.wrap
        raw
      end

      def coerce_error(coerced)
        return :array unless coerced.is_a?(Array)
      end
    end
  end
end
