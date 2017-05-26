# frozen_string_literal: true

module Objective
  module Filters
    class HashFilter < Objective::Filter
      Options = OpenStruct.new(
        none: Objective::DENY,
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false
      )

      def feed(raw)
        result = super(raw)
        return result if result == Objective::DISCARD || result.errors || result.inputs.nil?

        errors = Objective::Errors::ErrorHash.new
        inputs = HashWithIndifferentAccess.new

        data = result.coerced
        sub_filters_hash.each_pair do |key, key_filter|
          datum = data.key?(key) ? data[key] : Objective::NONE
          key_filter_result = key_filter.feed(datum)
          next if key_filter_result == Objective::DISCARD

          sub_data = key_filter_result.inputs
          sub_error = key_filter_result.errors

          if sub_error.nil?
            inputs[key] = sub_data
          else
            errors[key] = key_filter.handle_errors(sub_error)
          end
        end

        result.inputs = inputs
        result.errors = errors.present? ? errors : nil
        result
      end

      def coerce(raw)
        raw.try(:with_indifferent_access)
      end

      def coerce_error(coerced)
        return :hash unless coerced.is_a?(Hash)
      end
    end
  end
end
