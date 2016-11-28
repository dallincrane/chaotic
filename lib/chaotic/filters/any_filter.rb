# frozen_string_literal: true
module Chaotic
  module Filters
    class AnyFilter < Chaotic::Filter
      default_options(
        nils: true
      )
    end
  end
end
