# frozen_string_literal: true
module Chaotic
  module Errors
    class ErrorAtom
      # NOTE: in the future, could also pass in:
      #  - error type
      #  - value (eg, string :name, length: 5 # value=5)

      # ErrorAtom.new(:name, :too_short)
      # ErrorAtom.new(:name, :too_short, message: "is too short")
      def initialize(key, error_symbol, options = {})
        @key = key
        @symbol = error_symbol
        @message = options[:message]
        @index = options[:index]
      end

      def symbolic
        @symbol
      end

      def message
        @message ||= Chaotic.error_message_creator.message(@key, @symbol, index: @index)
      end

      def message_list
        Array(message)
      end
    end
  end
end
