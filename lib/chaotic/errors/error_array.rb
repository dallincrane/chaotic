# frozen_string_literal: true
module Chaotic
  module Errors
    class ErrorArray < Array
      def codes
        map { |e| e&.codes }
      end

      def message(parent_key = nil, _index = nil)
        each_with_index.map { |e, i| e&.message(parent_key, i) }
      end

      def message_list(parent_key = nil, _index = nil)
        each_with_index.map do |e, i|
          next if e.nil?
          e.message_list(parent_key, i)
        end.flatten.compact
      end
    end
  end
end
