# frozen_string_literal: true

require 'singleton'

module Objective
  class Allow
    include Singleton
  end
end

Objective::ALLOW = Objective::Allow.instance.freeze
