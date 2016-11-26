# frozen_string_literal: true
module Chaotic
  module Filters
    class HashFilter < Chaotic::Filter
      default_options(
        nils: false
      )

      def feed(data)
        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        return [data, :hash] unless data.is_a?(Hash)

        data = data.with_indifferent_access

        errors = Chaotic::Errors::ErrorHash.new
        filtered_data = HashWithIndifferentAccess.new

        sub_filters_hash.each_pair do |key, key_filter|
          data_element = data[key]

          if data.key?(key)
            sub_data, sub_error = key_filter.feed(data_element)

            if sub_error.nil?
              filtered_data[key] = sub_data
            elsif key_filter.discardable?(sub_error)
              data.delete(key)
            else
              errors[key] = create_key_error(key, sub_error)
            end
          end

          next if data.key?(key)

          if key_filter.default?
            filtered_data[key] = key_filter.default
          elsif key_filter.required? && !key_filter.discardable?(sub_error)
            errors[key] = create_key_error(key, :required)
          end
        end

        return [data, errors] if errors.any?
        [filtered_data, nil]
      end

      def create_key_error(key, sub_error)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorHash)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorArray)

        Chaotic::Errors::ErrorAtom.new(key, sub_error)
      end
    end
  end
end
