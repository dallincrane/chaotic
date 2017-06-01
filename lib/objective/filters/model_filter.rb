# frozen_string_literal: true

module Objective
  module Filters
    class ModelFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
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
