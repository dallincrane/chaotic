# frozen_string_literal: true
module Objective
  module Errors
    class ErrorAtom
      attr_reader :key, :codes, :type, :datum, :bound

      # ErrorAtom.new(:name, :too_short)
      # ErrorAtom.new(:name, :too_short, message: "is too short")
      def initialize(key, codes, options = {})
        @key = key # attribute
        @codes = codes
        @message = options[:message]
        @type = options[:type] # target class/filter of coercion
        @value = options[:value] # value given
        @bound = options[:bound] # value of validator
      end

      def message(parent_key = nil, index = nil)
        @message ||= Objective.error_message_creator.message(self, parent_key, index)
      end

      def message_list(parent_key = nil, index = nil)
        Array.wrap(message(parent_key, index))
      end
    end
  end
end
