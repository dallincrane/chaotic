# frozen_string_literal: true
module Chaotic
  class ValidationException < ::StandardError
    attr_accessor :errors

    def initialize(errors)
      self.errors = errors
    end

    def to_s
      self.errors.message_list.join('; ').to_s
    end
  end
end
