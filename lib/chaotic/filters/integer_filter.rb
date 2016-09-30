# frozen_string_literal: true
module Chaotic
  module Filters
    class IntegerFilter
      include Chaotic::Concerns::Filterable

      @default_options = {
        empty_is_nil: false,
        nils: false,
        remove_characters: ',',
        min: nil,
        max: nil,
        in: nil
      }

      def filter(data)
        data = nil if options[:empty_is_nil] && data == ''

        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        return [data, :empty] if data == ''

        # COERCION
        # FIXME: needs to be able to coerce from Float and BigDecimal
        #
        if data.is_a?(String)
          clean_data = data.gsub(/[#{remove_characters_list}]/, '')
          return [data, :integer] unless clean_data =~ /^[-+]?\d/
          data = clean_data.to_i
        end

        return [data, :integer] unless data.is_a?(Integer)

        return [data, :min] if options[:min] && data < options[:min]
        return [data, :max] if options[:max] && data > options[:max]
        return [data, :in] if options[:in] && !options[:in].include?(data)

        [data, nil]
      end

      private

      def remove_characters_list
        Array(options[:remove_characters]).join('')
      end
    end
  end
end
