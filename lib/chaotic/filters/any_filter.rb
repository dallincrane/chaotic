# frozen_string_literal: true
module Chaotic
  module Filters
    class AnyFilter < Chaotic::Filter
      default_options(
        nils: true
      )

      def feed(data)
        return handle_nil if data.nil?

        [data, nil]
      end
    end
  end
end
