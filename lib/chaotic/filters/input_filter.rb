# frozen_string_literal: true
module Chaotic
  module Filters
    class InputFilter
      include Chaotic::Concerns::Filterable

      @default_options = {}

      def filter(data)
        [data, nil]
      end
    end
  end
end
