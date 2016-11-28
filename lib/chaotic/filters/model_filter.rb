# frozen_string_literal: true
module Chaotic
  module Filters
    class ModelFilter < Chaotic::Filter
      default_options(
        nils: false,
        class: nil,
        new_records: false
      )

      private

      def coerce_error(coerced)
        return :model unless coerced.is_a?(class_constant)
      end

      def validate(coerced)
        return :new_records if !options.new_records && (coerced.respond_to?(:new_record?) && coerced.new_record?)
      end

      def class_constant
        klass = options[:class]
        return key.to_s.camelize.constantize if klass.nil?
        return klass if klass.instance_of? Class
        klass.to_s.constantize
      end
    end
  end
end
