# frozen_string_literal: true
module Chaotic
  class BooleanFilter < AdditionalFilter
    @default_options = {
      nils: false
    }

    BOOLEAN_MAP = {
      'true' => true,
      'false' => false,
      '1' => true,
      '0' => false,
      1 => true,
      0 => false
    }.freeze

    def filter(data)
      if data.nil?
        return [data, nil] if options[:nils]
        return [data, :nils]
      end

      return [data, :empty] if data == ''

      return [data, nil] if data == true || data == false

      if data.is_a?(String)
        res = BOOLEAN_MAP[data.downcase]
        return [res, nil] unless res.nil?
      end

      [data, :boolean]
    end
  end
end
