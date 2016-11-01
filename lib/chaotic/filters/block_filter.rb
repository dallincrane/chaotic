# frozen_string_literal: true
module Chaotic
  module Filters
    class BlockFilter
      attr_accessor :sub_filters

      # NOTE: using ||= here as sub_filters may exist in inhereted params
      @sub_filters ||= []

      # FIXME: make sure either all or none of the subfilters provide keys
      def self.register_filter(filter_class, filter_name)
        define_method(filter_name) do |*args, &block|
          args.unshift(nil) if args[0].is_a?(Hash)

          new_filter = filter_class.new(*args, &block)
          sub_filters.push(new_filter)
        end
      end

      # TODO: make this go deeper than one level
      # def dup
      #   dupped = BlockFilter.new
      #   sub_filters.each { |filter| dupped.sub_filters.push(filter) }
      #   dupped
      # end

      def build_filters(&block)
        instance_eval(&block)
      end

      def keys
        sub_filters.map(&:key)
      end

      def filter(data)
        errors = ErrorHash.new
        filtered_data = HashWithIndifferentAccess.new


        sub_filters.each_with_index do |sub_filter, idx|
          placement = sub_filter.key || idx

          if data.key?(placement)
            sub_data, sub_error = sub_filter.filter(data[placement])

            if sub_error.nil?
              filtered_data[key] = sub_data
            elsif discardable?(sub_error, sub_filter)
              data.delete(key)
            else
              errors[key] = ErrorAtom.new(key, sub_error)
            end
          end

          next if data.key?(key)

          if sub_filter.default?
            filtered_data[key] = sub_filter.default
          elsif sub_filter.required?
            errors[key] = ErrorAtom.new(key, :required)
          end
        end

        return [data, errors] if errors.any?
        [filtered_data, nil]
      end
    end
  end
end
