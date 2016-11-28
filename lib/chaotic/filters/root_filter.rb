# frozen_string_literal: true
module Chaotic
  module Filters
    class RootFilter < Chaotic::Filter
      def filter(&block)
        instance_eval(&block)
      end

      def keys
        sub_filters.map(&:key)
      end

      def feed(*given)
        coerced = coerce(given)
        input = OpenStruct.new
        errors = Chaotic::Errors::ErrorHash.new

        sub_filters_hash.each_pair do |key, key_filter|
          data_element = coerced[key]

          if coerced.respond_to?(key)
            key_filter_result = key_filter.feed(data_element)
            sub_data = key_filter_result.input
            sub_error = key_filter_result.error

            if sub_error.nil?
              input[key] = sub_data
            elsif key_filter.discardable?(sub_error)
              coerced.delete_field(key)
            else
              errors[key] = create_key_error(key, sub_error)
            end
          end

          next if coerced.respond_to?(key)

          if key_filter.default?
            input[key] = key_filter.default
          elsif key_filter.required? && !key_filter.discardable?(sub_error)
            errors[key] = create_key_error(key, :required)
          end
        end

        OpenStruct.new(
          raw: given,
          coerced: coerced,
          inputs: input,
          errors: errors.present? ? errors : nil
        )
      end

      def coerce(given)
        given.each_with_object(OpenStruct.new) do |datum, result|
          raise_argument_error unless datum.respond_to?(:each_pair)
          datum.each_pair { |key, value| result[key] = value }
        end
      end

      def raise_argument_error
        raise(ArgumentError, 'All Chaotic arguments must be a Hash or OpenStruct')
      end

      def create_key_error(key, sub_error)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorHash)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorArray)

        Chaotic::Errors::ErrorAtom.new(key, sub_error)
      end
    end
  end
end
