# frozen_string_literal: true
module Chaotic
  module Filters
    class FloatFilter
      include Concerns::Filterable

      @default_options = {
        empty_is_nil: false,
        nils: false,
        remove_characters: ',',
        min: nil,
        max: nil
      }

      def filter(data)
        data = nil if options[:empty_is_nil] && data == ''

        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        return [data, :empty] if data == ''

        # COERCION
        data = data.to_f if data.is_a?(Integer) || data.is_a?(BigDecimal)

        if data.is_a?(String) && data =~ /^[-+]?\d*\.?\d+/
          clean_data = data.gsub(/[#{remove_characters_list}]/, '')
          return [data, :float] unless clean_data =~ /\A[-+]?\d*\.?\d+\z/
          data = clean_data.to_f
        end

        # VALIDATION
        return [data, :float] unless data.is_a?(Float)
        return [data, :min] if options[:min] && data < options[:min]
        return [data, :max] if options[:max] && data > options[:max]

        [data, nil]
      end

      private

      def remove_characters_list
        Array(options[:remove_characters]).join('')
      end
    end
  end
end
