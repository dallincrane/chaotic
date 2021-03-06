# frozen_string_literal: true

module Objective
  module Filters
    class ArrayFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
        wrap: false
      )

      def feed(raw)
        result = super(raw)
        return result if result.errors || result.inputs.nil?

        inputs = []
        errors = Objective::Errors::ErrorArray.new

        sub_filter = sub_filters.first

        index_shift = 0

        data = result.coerced
        data.each_with_index do |sub_data, index|
          sub_result = sub_filter.feed(sub_data)
          sub_data = sub_result.inputs
          sub_error = sub_result.errors

          unless sub_error.nil?
            errors[index - index_shift] = sub_filter.handle_errors(sub_error)
          end

          inputs[index - index_shift] = sub_data
        end

        result.inputs = inputs
        result.errors = errors.empty? ? nil : errors
        result
      end

      def coerce(raw)
        return Objective::Helpers.wrap(raw) if options.wrap
        raw
      end

      def coerce_error(coerced)
        return :array unless coerced.is_a?(Array)
      end
    end
  end
end
