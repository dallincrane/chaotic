# frozen_string_literal: true
module Chaotic
  module Filters
    class ArrayFilter
      include Concerns::Filterable
      include Concerns::Blockable

      @default_options = {
        nils: false,
        arrayize: false
      }

      def filter(data)
        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        data = Array(data) if options[:arrayize] && !data.is_a?(Array)

        return [data, :array] unless data.is_a?(Array)

        errors = ErrorArray.new
        filtered_data = []

        data.each_with_index do |sub_data, index|
          sub_data, sub_error = sub_filter.filter(sub_data)

          if sub_error.nil?
            filtered_data << sub_data
          elsif discardable?(sub_error, sub_filter)
            if sub_filter.default?
              filtered_data << sub_filter.default
            else
              errors << ErrorAtom.new(key, :required)
            end
          else
            errors << ErrorAtom.new(@name, sub_error, index: index)
          end
        end

        return [filtered_data, errors] if errors.any?
        [filtered_data, nil]
      end
    end
  end
end
