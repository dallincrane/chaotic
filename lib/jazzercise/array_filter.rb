# frozen_string_literal: true
module Chaotic
  class ArrayFilter < InputFilter
    def self.register_additional_filter(type_class, type_name)
      define_method(type_name) do |*args, &block|
        options = args[0] || {}
        @element_filter = type_class.new(options, &block)
      end
    end

    @default_options = {
      nils: false,
      class: nil,
      arrayize: false
    }

    def initialize(name, opts = {}, &block)
      super(opts)

      @name = name
      @element_filter = nil

      if block_given?
        instance_eval &block
      end

      raise ArgumentError.new("Can't supply both a class and a filter") if @element_filter && self.options[:class]
    end

    def hash(options = {}, &block)
      @element_filter = HashFilter.new(options, &block)
    end

    def model(name, options = {})
      @element_filter = ModelFilter.new(name.to_sym, options)
    end

    def array(options = {}, &block)
      @element_filter = ArrayFilter.new(nil, options, &block)
    end

    def filter(data)
      # Handle nil case
      if data.nil?
        return [data, nil] if options[:nils]
        return [data, :nils]
      end

      if !data.is_a?(Array) && options[:arrayize]
        # FIXME: why can't we arrayize an empty string??
        return [[], nil] if data == ''
        data = Array(data)
      end

      if data.is_a?(Array)
        errors = ErrorArray.new
        filtered_data = []
        found_error = false
        data.each_with_index do |el, i|
          el_filtered, el_error = filter_element(el)
          el_error = ErrorAtom.new(@name, el_error, :index => i) if el_error.is_a?(Symbol)
          errors << el_error
          if el_error
            found_error = true
          else
            filtered_data << el_filtered
          end
        end

        if found_error && !(@element_filter && @element_filter.discard_invalid?)
          [data, errors]
        else
          [filtered_data, nil]
        end
      else
        return [data, :array]
      end
    end

    # Returns [filtered, errors]
    def filter_element(data)
      if @element_filter
        data, el_errors = @element_filter.filter(data)
        return [data, el_errors] if el_errors
      elsif options[:class]
        class_const = options[:class]
        class_const = class_const.constantize if class_const.is_a?(String)

        if !data.is_a?(class_const)
          return [data, :class]
        end
      end

      [data, nil]
    end
  end
end
