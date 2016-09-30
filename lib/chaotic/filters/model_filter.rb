# frozen_string_literal: true
module Chaotic
  module Filters
    class ModelFilter
      include Chaotic::Concerns::Filterable

      @default_options = {
        nils: false,
        class: nil,
        builder: nil,
        new_records: false
      }

      def initialize(name, opts = {})
        super(opts)
        @name = name
      end

      def filter(data)
        initialize_constants!

        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        # Passing in attributes.  Let's see if we have a builder
        if data.is_a?(Hash) && options[:builder]
          ret = options[:builder].run(data)

          return [data, ret.errors] unless ret.success?
          data = ret.result
        end

        # We have a winner, someone passed in the correct data type!
        if data.is_a?(options[:class])
          return [data, :new_records] if !options[:new_records] && (data.respond_to?(:new_record?) && data.new_record?)
          return [data, nil]
        end

        [data, :model]
      end

      private

      # Initialize the model class and builder
      def initialize_constants!
        @initialize_constants ||= begin
          class_const = options[:class] || @name.to_s.camelize
          class_const = class_const.constantize if class_const.is_a?(String)
          options[:class] = class_const

          if options[:builder]
            options[:builder] = options[:builder].constantize if options[:builder].is_a?(String)
          end

          true
        end

        unless Chaotic.cache_constants?
          options[:class] = options[:class].to_s.constantize if options[:class]
          options[:builder] = options[:builder].to_s.constantize if options[:builder]
        end
      end
    end
  end
end
