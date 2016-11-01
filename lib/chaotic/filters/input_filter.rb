# frozen_string_literal: true
module Chaotic
  module Filters
    class InputFilter < Chaotic::Filter
      DEFAULT_OPTIONS = {}.freeze

      def filter(data)
        [data, nil]
      end
    end
  end
end
