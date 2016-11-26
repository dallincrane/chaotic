# frozen_string_literal: true
module Chaotic
  module Filters
    class InputFilter < Chaotic::Filter
      def feed(data)
        [data, nil]
      end
    end
  end
end
