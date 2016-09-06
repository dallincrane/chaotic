# frozen_string_literal: true
module Chaotic
  class StringFilter < AdditionalFilter
    @default_options = {
      nils: false,
      strict: false,
      allow_control_characters: false,
      strip: true,
      empty: false,
      min_length: nil,
      max_length: nil,
      in: nil,
      matches: nil,
      discard_empty: false, # FIXME: is this needed here?
    }

    def filter(data)
      if data.nil?
        return [data, nil] if options[:nils]
        return [data, :nils]
      end

      data = data.to_s if !options[:strict] && [TrueClass, FalseClass, Fixnum, Float, BigDecimal, Symbol].include?(data.class)
      return [data, :string] unless data.is_a?(String)

      data = data.gsub(/[^[:print:]\t\r\n]+/, ' ') unless options[:allow_control_characters]
      data = data.strip if options[:strip]

      if data == ''
        return [data, nil] if options[:empty]
        return [data, :empty]
      end

      return [data, :min_length] if options[:min_length] && data.length < options[:min_length]
      return [data, :max_length] if options[:max_length] && data.length > options[:max_length]
      return [data, :in] if options[:in] && !options[:in].include?(data)
      return [data, :matches] if options[:matches] && (options[:matches] !~ data)
      [data, nil]
    end
  end
end