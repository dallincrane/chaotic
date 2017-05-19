# frozen_string_literal: true
require 'singleton'

module Objective
  class Deny
    include Singleton
  end
end

Objective::DENY = Objective::Deny.instance.freeze
