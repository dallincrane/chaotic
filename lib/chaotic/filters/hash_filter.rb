# frozen_string_literal: true
module Chaotic
  module Filters
    class HashFilter < Chaotic::Filter
      default_options(
        nils: false
      )

      def feed(raw)
        result = super(raw)
        return result if result == Chaotic::DISCARD || result.errors || result.inputs.nil?

        errors = Chaotic::Errors::ErrorHash.new
        inputs = HashWithIndifferentAccess.new

        data = result.coerced
        sub_filters_hash.each_pair do |key, key_filter|
          datum = data.key?(key) ? data[key] : Chaotic::NONE
          key_filter_result = key_filter.feed(datum)
          next if key_filter_result == Chaotic::DISCARD

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
