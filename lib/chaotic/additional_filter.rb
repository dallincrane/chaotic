# frozen_string_literal: true
require 'chaotic/hash_filter'
require 'chaotic/array_filter'

module Chaotic
  class AdditionalFilter < InputFilter
    def self.inherited(subclass)
      type_name = subclass.name[/^Chaotic::([a-zA-Z]*)Filter$/, 1].underscore

      Chaotic::HashFilter.register_additional_filter(subclass, type_name)
      Chaotic::ArrayFilter.register_additional_filter(subclass, type_name)
    end
  end
end
