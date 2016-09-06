# frozen_string_literal: true
module Chaotic
  class DuckFilter < AdditionalFilter
    @default_options = {
      nils: false,
      methods: nil
    }

    def filter(data)
      if data.nil?
        return [data, nil] if options[:nils]
        return [data, :nils]
      end

      Array(options[:methods]).each do |method|
        return [data, :duck] unless data.respond_to?(method)
      end

      [data, nil]
    end
  end
end
