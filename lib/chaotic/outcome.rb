# frozen_string_literal: true
module Chaotic
  class Outcome
    attr_reader :result, :errors, :inputs

    def initialize(success, result, errors, inputs)
      @success = success
      @result = result
      @errors = errors
      @inputs = inputs
    end

    def success?
      @success
    end
  end
end
