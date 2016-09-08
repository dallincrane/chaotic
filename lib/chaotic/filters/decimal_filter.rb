# frozen_string_literal: true
module Mutations
  module Filters
    class DecimalFilter
      include Concerns::Filterable

      @default_options = {
        empty_is_nil: false,
        nils: false,
        remove_characters: ',',
        min: nil,
        max: nil,
        scale: nil
      }

      def filter(data)
        data = nil if options[:empty_is_nil] && data == ''

        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        return [data, :empty] if data == ''

        # COERCION
        data = data.to_d if data.is_a?(Float) || data.is_a?(Integer)

        if data.is_a?(String)
          clean_data = data.gsub(/[#{remove_characters_list}]/, '')
          data = clean_data.to_d if clean_data =~ /\A[-+]?\d*\.?\d+\z/
        end

        # VALIDATION
        return [data, :decimal] unless data.is_a?(BigDecimal)
        return [data, :min] if options[:min] && data < options[:min]
        return [data, :max] if options[:max] && data > options[:max]
        return [data, :scale] if options[:scale] && !within_scale?(data)

        [data, nil]
      end

      private

      def remove_characters_list
        Array(options[:remove_characters]).join('')
      end

      def within_scale?(data)
        (data - data.round(options[:scale])).zero?
      end
    end
  end
end
