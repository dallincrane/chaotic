# frozen_string_literal: true
module Chaotic
  module Filters
    class HashFilter < Chaotic::Filter
      default_options(
        nils: false
      )

      def feed(raw)
        result = super(raw)
        return result if result.errors || result.inputs.nil?

        errors = Chaotic::Errors::ErrorHash.new
        inputs = HashWithIndifferentAccess.new

        data = result.coerced
        sub_filters_hash.each_pair do |key, key_filter|
          data_element = data[key]

          if data.key?(key)
            key_filter_result = key_filter.feed(data_element)
            sub_data = key_filter_result.inputs
            sub_error = key_filter_result.errors

            if sub_error.nil?
              inputs[key] = sub_data
            elsif key_filter.discardable?(sub_error)
              data.delete(key)
            else
              errors[key] = create_key_error(key, sub_error)
            end
          end

          next if data.key?(key)

          if key_filter.default?
            inputs[key] = key_filter.default
          elsif key_filter.required? && !key_filter.discardable?(sub_error)
            errors[key] = create_key_error(key, :required)
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

      def create_key_error(key, sub_error)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorHash)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorArray)

        Chaotic::Errors::ErrorAtom.new(key, sub_error)
      end
    end
  end
end
