# frozen_string_literal: true

module Objective
  module Helpers
    # copied from activesupport
    # https://github.com/rails/rails/blob/v5.1.1/activesupport/lib/active_support/core_ext/array/wrap.rb
    def self.wrap(obj)
      if obj.nil?
        []
      elsif obj.respond_to?(:to_ary)
        obj.to_ary || [obj]
      else
        [obj]
      end
    end

    # copied from activesupport
    # https://github.com/rails/rails/blob/v5.1.1/activesupport/lib/active_support/inflector/methods.rb
    def self.constantize(camel_cased_word)
      names = camel_cased_word.split('::'.freeze)
      Object.const_get(camel_cased_word) if names.empty?
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          constant = constant.ancestors.inject(constant) do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          constant.const_get(name, false)
        end
      end
    end
  end
end
