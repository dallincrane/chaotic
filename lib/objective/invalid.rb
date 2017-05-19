# frozen_string_literal: true
require 'singleton'

module Objective
  class Invalid
    include Singleton
  end
end

Objective::INVALID = Objective::Invalid.instance.freeze
