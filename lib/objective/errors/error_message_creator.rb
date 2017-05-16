# frozen_string_literal: true
module Objective
  module Errors
    class ErrorMessageCreator
      MESSAGES = Hash.new('is invalid').tap do |h|
        h.merge!(
          nils: 'cannot be nil',
          required: 'is required',

          string: 'must be a string',
          integer: 'must be an integer',
          decimal: 'must be a number',
          boolean: 'must be a boolean',
          hash: 'must be a hash',
          array: 'must be an array',
          model: 'must be the right class',
          date: 'date does non exist',

          before: 'must be before given date',
          after: 'must be after given date',
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
          (atom.key || parent_key || 'item').to_s.titleize,
          MESSAGES[atom.codes]
        ]
          .compact
          .join(' ')
      end

      def index_ordinal(index)
        index&.+(1)&.ordinalize
      end
    end
  end
end
