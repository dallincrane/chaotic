# frozen_string_literal: true
module Chaotic
  module Errors
    class ErrorHash < HashWithIndifferentAccess
      # chaotic.errors is an ErrorHash instance like this:
      # {
      #   email: ErrorAtom(:matches),
      #   name: ErrorAtom(:too_weird, message: "is too weird"),
      #   adddress: { # Nested ErrorHash object
      #     city: ErrorAtom(:not_found, message: "That's not a city, silly!"),
      #     state: ErrorAtom(:in)
      #   }
      # }

      # Returns a nested HashWithIndifferentAccess where the values are symbols.  Eg:
      # {
      #   email: :matches,
      #   name: :too_weird,
      #   adddress: {
      #     city: :not_found,
      #     state: :in
      #   }
      # }
      def symbolic
        HashWithIndifferentAccess.new.tap do |hash|
          each do |k, v|
            hash[k] = v.symbolic
          end
        end
      end

      # Returns a nested HashWithIndifferentAccess where the values are messages. Eg:
      # {
      #   email: "isn't in the right format",
      #   name: "is too weird",
      #   adddress: {
      #     city: "is not a city",
      #     state: "isn't a valid option"
      #   }
      # }
      def message
        HashWithIndifferentAccess.new.tap do |hash|
          each do |k, v|
            hash[k] = v.message
          end
        end
      end

      # Returns a flat array where each element is a full sentence. Eg:
      # [
      #   "Email isn't in the right format.",
      #   "Name is too weird",
      #   "That's not a city, silly!",
      #   "State isn't a valid option."
      # ]
      def message_list
        list = []
        each do |_k, v|
          list.concat(v.message_list)
        end
        list
      end
    end
  end
end
