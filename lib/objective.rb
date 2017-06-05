# frozen_string_literal: true

require 'ostruct'
require 'date'
require 'time'
require 'bigdecimal'
require 'bigdecimal/util'

require 'objective/allow'
require 'objective/deny'

require 'objective/helpers'

require 'objective/errors/error_atom'
require 'objective/errors/error_hash'
require 'objective/errors/error_array'
require 'objective/errors/error_message_creator'
require 'objective/errors/validation_error'

require 'objective/filter'
require 'objective/filters/any_filter'
require 'objective/filters/array_filter'
require 'objective/filters/boolean_filter'
require 'objective/filters/date_filter'
require 'objective/filters/decimal_filter'
require 'objective/filters/duck_filter'
require 'objective/filters/file_filter'
require 'objective/filters/float_filter'
require 'objective/filters/hash_filter'
require 'objective/filters/integer_filter'
require 'objective/filters/model_filter'
require 'objective/filters/root_filter'
require 'objective/filters/string_filter'
require 'objective/filters/symbol_filter'
require 'objective/filters/time_filter'

require 'objective/unit'
require 'objective/outcome'

module Objective
  def self.error_message_creator
    @@error_message_creator
  end

  def self.error_message_creator=(obj)
    @@error_message_creator = obj
  end

  self.error_message_creator = Errors::ErrorMessageCreator.new
end
