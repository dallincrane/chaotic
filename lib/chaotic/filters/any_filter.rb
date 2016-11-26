# frozen_string_literal: true
module Chaotic
  module Filters
    class AnyFilter < Chaotic::Filter
      default_options(
        nils: true
      )

      def feed(data)
        if data.nil?
          return [nil, nil] if options.nils
          return [nil, :nils]
        end

        [data, nil]
      end
    end
  end
end
