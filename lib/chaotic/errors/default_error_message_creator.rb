# frozen_string_literal: true
module Chaotic
  module Errors
    class DefaultErrorMessageCreator
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

      def message(key, error_symbol, options = {})
        [
          options[:index]&.+(1)&.ordinalize,
          key_display_name(key),
          MESSAGES[error_symbol]
        ]
          .compact
          .join(' ')
      end

      private

      def key_display_name(key)
        (key || 'item').to_s.titleize
      end
    end
  end
end
