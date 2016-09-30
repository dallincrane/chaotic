# frozen_string_literal: true
module Chaotic
  module Filters
    class HashFilter
      include Chaotic::Concerns::Filterable
      include Chaotic::Concerns::Blockable

      @default_options = {
        nils: false
      }

      # TODO: make this go deeper than one level
      def dup
        dupped = HashFilter.new
        sub_filters.each_pair { |k, v| dupped.sub_filters[k] = v }
        dupped
      end

      def params(&block)
        instance_eval(&block)
      end

      def keys
        sub_filters.keys
      end

      def filter(data)
        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        return [data, :hash] unless data.is_a?(Hash)

        unless data.is_a?(HashWithIndifferentAccess)
          data = data.with_indifferent_access
        end

        errors = ErrorHash.new
        filtered_data = HashWithIndifferentAccess.new

        sub_filters.each_pair do |key, key_filter|
          data_element = data[key]

          if data.key?(key)
            sub_data, sub_error = key_filter.filter(data_element)

            if sub_error.nil?
              filtered_data[key] = sub_data
            elsif discardable?(sub_error, key_filter)
              data.delete(key)
            else
              errors[key] = ErrorAtom.new(key, sub_error)
            end
          end

          next if data.key?(key)

          if key_filter.default?
            filtered_data[key] = key_filter.default
          elsif key_filter.required?
            errors[key] = ErrorAtom.new(key, :required)
          end
        end

        return [data, errors] if errors.any?
        [filtered_data, nil]
      end
    end
  end
end
