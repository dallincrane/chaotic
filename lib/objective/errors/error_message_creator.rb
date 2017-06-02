# frozen_string_literal: true

module Objective
  module Errors
    class ErrorMessageCreator
      MESSAGES = Hash.new('is invalid').tap do |h|
        h.merge!(
          nils: 'cannot be nil',

          string: 'must be a string',
          integer: 'must be an integer',
          decimal: 'must be a number',
          boolean: 'must be a boolean',
          hash: 'must be a hash',
          array: 'must be an array',
          model: 'must be the right class',
          date: 'date does non exist',

          empty: 'cannot be empty',
          matches: 'has an incorrect format',
          in: 'is not an available option',
          min: 'is too small',
          max: 'is too big',
          new_records: 'model must be saved'
        )
      end

      def message(atom, parent_key, index)
        [
          index_ordinal(index),
          (atom.key || parent_key || 'item').to_s,
          MESSAGES[atom.codes]
        ]
          .compact
          .join(' ')
      end

      def index_ordinal(index)
        return if index.nil?
        ordinalize_index(index)
      end

      def ordinalize_index(index)
        number = index + 1

        ordinal =
          if (11..13).cover?(number % 100)
            'th'
          else
            case number % 10
            when 1 then 'st'
            when 2 then 'nd'
            when 3 then 'rd'
            else 'th'
            end
          end

        "#{number}#{ordinal}"
      end
    end
  end
end
