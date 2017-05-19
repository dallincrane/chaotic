# frozen_string_literal: true
require 'singleton'

module Objective
  class Discard
    include Singleton
  end
end

Objective::DISCARD = Objective::Discard.instance.freeze
