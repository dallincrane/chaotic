# frozen_string_literal: true
module Chaotic
  class IntegerFilter < AdditionalFilter
    @default_options = {
      nils: false,
      empty_is_nil: false,
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

      unless data.is_a?(Fixnum)
        if data.is_a?(String) && data =~ /^-?\d/
          data = data.to_i
        else
          return [data, :integer]
        end
      end

      return [data, :min] if options[:min] && data < options[:min]
      return [data, :max] if options[:max] && data > options[:max]
      return [data, :in] if options[:in] && !options[:in].include?(data)

      [data, nil]
    end
  end
end
