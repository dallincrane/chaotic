# frozen_string_literal: true
module Chaotic
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
          max_length: 'is too long',
          min_length: 'is too short',
          matches: 'has an incorrect format',
          in: 'is not an available option',

          min: 'is too small',
          max: 'is too big',

          new_records: 'model must be saved'
        )
      end

      def message(error_atom)
        [
          error_atom.index_ordinal,
          (error_atom.key || 'item').to_s.titleize,
          MESSAGES[error_atom.symbolic]
        ]
          .compact
          .join(' ')
      end
    end
  end
end
