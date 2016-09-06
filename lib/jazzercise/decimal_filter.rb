# frozen_string_literal: true
module Mutations
  class DecimalFilter < AdditionalFilter
    @default_options = {
      empty_is_nil: false,
      nils: false,
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

      unless data.is_a?(BigDecimal)
        if data.is_a?(String)
          clean_data = data.gsub(/[$,]/, '')
          return [data, :decimal] unless clean_data =~ /\A[-+]?\d*\.?\d+\z/
          data = clean_data.to_d
        elsif data.is_a?(Float)
          data = data.to_d
        elsif data.is_a?(Fixnum)
          data = data.to_d
        else
          return [data, :decimal]
        end
      end

      return [data, :min] if options[:min] && data < options[:min]
      return [data, :max] if options[:max] && data > options[:max]
      return [data, :scale] if options[:scale] && !within_scale?(data)

      [data, nil]
    end

    private

    def within_scale?(data)
      (data - data.round(options[:scale])).zero?
    end
  end
end
