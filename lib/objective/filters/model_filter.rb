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
        class_name = options[:class] || key.to_s.split('_').collect(&:capitalize).join

        return class_name if class_name.instance_of? Class
        Objective::Helpers.constantize(class_name.to_s)
      end
    end
  end
end
