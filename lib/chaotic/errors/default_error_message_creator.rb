# frozen_string_literal: true
module Chaotic
  module Errors
    class DefaultErrorMessageCreator
      MESSAGES = Hash.new('is invalid').tap do |h|
        h.merge!(
          # General
          nils: 'can\'t be nil',
          required: 'is required',

          # Datatypes
          string: 'isn\'t a string',
          integer: 'isn\'t an integer',
          boolean: 'isn\'t a boolean',
          hash: 'isn\'t a hash',
          array: 'isn\'t an array',
          model: 'isn\'t the right class',

          # Date
          date: 'date doesn\'t exist',
          before: 'isn\'t before given date',
          after: 'isn\'t after given date',

          # String
          empty: 'can\'t be blank',
          max_length: 'is too long',
          min_length: 'is too short',
          matches: 'isn\'t in the right format',
          in: 'isn\'t an option',

          # Array
          class: 'isn\'t the right class',

          # Integer
          min: 'is too small',
          max: 'is too big',

          # Model
          new_records: 'isn\'t a saved model'
        )
      end

      # key: the name of the field, eg, :email. Could be nil if it's an array element
      # error_symbol: the validation symbol, eg, :matches or :required
      # options:
      #  :index -- index of error if it's in an array
      def message(key, error_symbol, options = {})
        if options[:index]
          "#{(key || 'array').to_s.titleize}[#{options[:index]}] #{MESSAGES[error_symbol]}"
        else
          "#{key.to_s.titleize} #{MESSAGES[error_symbol]}"
        end
      end
    end
  end
end
