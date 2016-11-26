# frozen_string_literal: true
module Chaotic
  module Filters
    class ArrayFilter < Chaotic::Filter
      default_options(
        nils: false,
        arrayize: false
      )

      def feed(data)
        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        data = Array.wrap(data) if options[:arrayize]

        return [data, :array] unless data.is_a?(Array)

        errors = Chaotic::Errors::ErrorArray.new
        filtered_data = []

        sub_filter = sub_filters.first

        index_shift = 0

        data.each_with_index do |sub_data, index|
          sub_data, sub_error = sub_filter.feed(sub_data)

          if sub_error.nil?
            filtered_data << sub_data
          elsif sub_filter.discardable?(sub_error)
            if sub_filter.default?
              filtered_data << sub_filter.default
            else
              index_shift += 1
            end
          else
            relative_index = index - index_shift
            errors[relative_index] = create_index_error(relative_index, sub_error)
            filtered_data << sub_data
          end
        end

        return [filtered_data, errors] if errors.any?
        [filtered_data, nil]
      end

      def create_index_error(index, sub_error)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorHash)
        return sub_error if sub_error.is_a?(Chaotic::Errors::ErrorArray)

        Chaotic::Errors::ErrorAtom.new(key, sub_error, index: index)
      end
    end
  end
end
