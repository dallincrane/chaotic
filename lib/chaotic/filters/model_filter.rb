# frozen_string_literal: true
module Chaotic
  module Filters
    class ModelFilter < Chaotic::Filter
      default_options(
        nils: false,
        class: nil,
        builder: nil,
        new_records: false,
        cache_constants: true
      )

      def feed(data)
        initialize_constants!

        return handle_nil if data.nil?

        if data.is_a?(Hash) && options.builder
          ret = builder_constant.run(data)

          return [data, ret.errors] unless ret.success
          data = ret.result
        end

        if data.is_a?(class_constant)
          return [data, :new_records] if !options.new_records && (data.respond_to?(:new_record?) && data.new_record?)
          return [data, nil]
        end

        [data, :model]
      end

      private

      def initialize_constants!
        class_constant
        builder_constant
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

      def builder_constant
        return unless options.builder
        @builder_constant ||= nil
        return @builder_constant if @builder_constant
        result = deduce_builder_constant
        @builder_constant = result if options.cache_constants
        result
      end

      def deduce_builder_constant
        builder = options.builder
        return builder if builder.instance_of? Class
        builder.to_s.constantize
      end
    end
  end
end
