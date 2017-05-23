# frozen_string_literal: true
module Objective
  module Filters
    class AnyFilter < Objective::Filter
      Options = OpenStruct.new(
        none: Objective::DENY,
        nils: Objective::ALLOW,
        invalid: Objective::DENY,
        strict: false
      )
    end
  end
end
