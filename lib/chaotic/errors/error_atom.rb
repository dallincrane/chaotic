# frozen_string_literal: true
module Chaotic
  module Errors
    class ErrorAtom
      attr_reader :key, :type, :index, :datum, :bound
      # NOTE: in the future, could also pass in:
      #  - error type
      #  - bound (eg, string :name, length: 5 # bound=5)

      # ErrorAtom.new(:name, :too_short)
      # ErrorAtom.new(:name, :too_short, message: "is too short")
      def initialize(key, error_symbol, options = {})
        @key = key # attribute
        @symbol = error_symbol
        @message = options[:message]
        @type = options[:type] # target class/filter of coercion
        @index = options[:index]
        @value = options[:value] # value given
        @bound = options[:bound] # value of validator
      end

      def symbolic
        @symbol
      end

      def index_ordinal
        index&.+(1)&.ordinalize
      end

      def message
        @message ||= Chaotic.error_message_creator.message(self)
      end

      def message_list
        Array(message)
      end
    end
  end
end
