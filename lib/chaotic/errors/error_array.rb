# frozen_string_literal: true
module Chaotic
  module Errors
    class ErrorArray < Array
      def symbolic
        map { |e| e&.symbolic }
      end

      def message
        map { |e| e&.message }
      end

      def message_list
        compact.map(&:message_list).flatten
      end
    end
  end
end
