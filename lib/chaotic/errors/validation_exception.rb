# frozen_string_literal: true
module Chaotic
  module Errors
    class ValidationException < ::StandardError
      attr_accessor :errors

      def initialize(errors)
        self.errors = errors
      end

      def to_s
        errors.message_list.join('; ').to_s
      end
    end
  end
end
