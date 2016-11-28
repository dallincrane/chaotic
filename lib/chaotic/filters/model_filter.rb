# frozen_string_literal: true
module Chaotic
  module Filters
    class ModelFilter < Chaotic::Filter
      default_options(
        nils: false,
        class: nil,
        new_records: false,
        cache_constants: true
      )

      def feed(raw)
        initialize_constants!
        super(raw)
      end

      private

      def coerce_error(coerced)
        return :model unless coerced.is_a?(class_constant)
      end

      def validate(input)
        return :new_records if !options.new_records && (input.respond_to?(:new_record?) && input.new_record?)
      end

      def initialize_constants!
        class_constant
      end

      def class_constant
        @class_constant ||= nil
        return @class_constant if @class_constant
        result = deduce_class_constant
        @class_constant = result if options.cache_constants
        result
      end

      def deduce_class_constant
        klass = options[:class]
        return key.to_s.camelize.constantize if klass.nil?
        return klass if klass.instance_of? Class
        klass.to_s.constantize
      end
    end
  end
end
