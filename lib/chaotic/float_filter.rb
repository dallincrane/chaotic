# frozen_string_literal: true
module Chaotic
  class FloatFilter < AdditionalFilter
    @default_options = {
      nils: false,
      min: nil,
      max: nil
    }

    def filter(data)
      if data.nil?
        return [data, nil] if options[:nils]
        return [data, :nils]
      end

      return [data, :empty] if data == ''

      unless data.is_a?(Float)
        if data.is_a?(String) && data =~ /^[-+]?\d*\.?\d+/
          data = data.to_f
        elsif data.is_a?(Fixnum)
          data = data.to_f
        else
          return [data, :float]
        end
      end

      return [data, :min] if options[:min] && data < options[:min]
      return [data, :max] if options[:max] && data > options[:max]

      [data, nil]
    end
  end
end
