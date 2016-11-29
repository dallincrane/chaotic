# frozen_string_literal: true
module Chaotic
  module Errors
    class ErrorAtom
      attr_reader :key, :codes, :type, :datum, :bound
      attr_writer :key
      # NOTE: in the future, could also pass in:
      #  - error type
      #  - bound (eg, string :name, length: 5 # bound=5)

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
        @message ||= Chaotic.error_message_creator.message(self, parent_key, index)
      end

      def message_list(parent_key = nil, index = nil)
        Array.wrap(message(parent_key, index))
      end
    end
  end
end
