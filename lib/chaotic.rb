# frozen_string_literal: true
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'date'
require 'time'
require 'bigdecimal'

require 'chaotic/exception'
require 'chaotic/errors'
require 'chaotic/input_filter'
require 'chaotic/additional_filter'
require 'chaotic/string_filter'
require 'chaotic/integer_filter'
require 'chaotic/float_filter'
require 'chaotic/boolean_filter'
require 'chaotic/duck_filter'
require 'chaotic/date_filter'
require 'chaotic/time_filter'
require 'chaotic/file_filter'
require 'chaotic/model_filter'
require 'chaotic/array_filter'
require 'chaotic/hash_filter'
require 'chaotic/outcome'
require 'chaotic/command'

module Chaotic
  class << self
    attr_writer :error_message_creator, :cache_constants

    def error_message_creator
      @error_message_creator ||= DefaultErrorMessageCreator.new
    end

    def cache_constants?
      @cache_constants
    end
  end
end

Chaotic.cache_constants = true
