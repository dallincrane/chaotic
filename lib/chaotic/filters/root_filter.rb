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

      def feed(*raw)
        result = OpenStruct.new
        result.raw = raw
        result.coerced = coerce(raw)

        inputs = OpenStruct.new
        errors = Chaotic::Errors::ErrorHash.new

        data = result.coerced
        sub_filters_hash.each_pair do |key, key_filter|
          datum = data.to_h.key?(key) ? data[key] : Chaotic::None
          key_filter_result = key_filter.feed(datum)
          next unless key_filter_result

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
        raw.each_with_object(OpenStruct.new) do |datum, result|
          raise_argument_error unless datum.respond_to?(:each_pair)
          datum.each_pair { |key, value| result[key] = value }
        end
      end

      def raise_argument_error
        raise(ArgumentError, 'All Chaotic arguments must be a Hash or OpenStruct')
      end
    end
  end
end
