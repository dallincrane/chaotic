# frozen_string_literal: true

require 'singleton'

module Objective
  class None
    include Singleton
  end
end

Objective::NONE = Objective::None.instance.freeze
