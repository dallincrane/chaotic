# frozen_string_literal: true
module Chaotic
  module Concerns
    module Blockable
      extend ActiveSupport::Concern

      included do
        attr_accessor :sub_filter
        attr_accessor :sub_filters

        # NOTE: using ||= here as sub_filters may exist in inhereted params
        @sub_filters ||= {}

        Chaotic::Filters.constants.each do |constant|
          match_data = /^Chaotic::Filters::([A-Z][a-zA-Z]*)Filter$/.match(constant.to_s)
          next unless match_data
          type_name = match_data[1].underscore

          define_method(type_name) do |*args, &block|
            args.unshift(nil) if args[0].is_a?(Hash)
            key, options = args

            new_filter = constant.new(key, options, &block)
            key ? sub_filters[key] = new_filter : self.sub_filter = new_filter
          end
        end
      end

      def run_block
        instance_eval(&block) if block_given?
      end

      def discardable?(sub_error, key_filter)
        return true if key_filter.discard_invalid?
        return true if key_filter.discard_empty? && sub_error == :empty
        return true if key_filter.discard_nils? && sub_error == :nil

        false
      end

      def discard_nils?
        options[:discard_nils]
      end

      def discard_empty?
        options[:discard_empty]
      end

      def discard_invalid?
        options[:discard_invalid]
      end
    end
  end
end
