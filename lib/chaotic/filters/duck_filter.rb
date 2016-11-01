# frozen_string_literal: true
module Chaotic
  module Filters
    class DuckFilter < Chaotic::Filter
      DEFAULT_OPTIONS = {
        nils: false,
        methods: nil
      }.freeze

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
end
