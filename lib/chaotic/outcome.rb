# frozen_string_literal: true
module Chaotic
  class Outcome
    attr_reader :result, :errors, :inputs

    def initialize(args)
      @success = args[:success]
      @result = args[:result]
      @errors = args[:errors]
      @inputs = args[:inputs]
    end

    def success?
      @success
    end
  end
end
