# frozen_string_literal: true
require 'ostruct'
require 'date'
require 'time'
require 'bigdecimal'
require 'bigdecimal/util'

require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/inflections'

require 'objective/allow'
require 'objective/deny'
require 'objective/discard'
require 'objective/invalid'
require 'objective/none'

require 'objective/errors/error_atom'
require 'objective/errors/error_hash'
require 'objective/errors/error_array'
require 'objective/errors/error_message_creator'
require 'objective/errors/validation_error'

require 'objective/filter'
require 'objective/filters'
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
require 'objective/filters/time_filter'

require 'objective/unit'
require 'objective/outcome'

module Objective
  mattr_accessor :error_message_creator
  self.error_message_creator = Errors::ErrorMessageCreator.new
end
