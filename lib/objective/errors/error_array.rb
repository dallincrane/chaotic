# frozen_string_literal: true

module Objective
  module Errors
    class ErrorArray < Array
      def codes
        map do |e|
          next unless e.respond_to?(:codes)
          e.codes
        end
      end

      def message(parent_key = nil, _index = nil)
        each_with_index.map do |e, i|
          next if e.nil?
          e.message(parent_key, i)
        end
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
