# frozen_string_literal: true
module Chaotic
  module Filters
    class DateFilter
      include Concerns::Filterable

      @default_options = {
        nils: false,  # true allows an explicit nil to be valid. Overrides any other options
        format: nil,  # If nil, Date.parse will be used for coercion. If something like "%Y-%m-%d", Date.strptime is used
        after: nil,   # A date object, representing the minimum date allowed, inclusive
        before: nil   # A date object, representing the maximum date allowed, inclusive
      }

      def filter(data)
        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        # Now check if it's empty:
        return [data, :empty] if data == ''

        if data.is_a?(Date) # Date and DateTime
          actual_date = data
        elsif data.is_a?(String)
          begin
            actual_date = parse(data)
          rescue ArgumentError
            return [nil, :date]
          end
        elsif data.respond_to?(:to_date) # Time
          actual_date = data.to_date
        else
          return [nil, :date]
        end

        return [nil, :after] if options[:after] && actual_date <= options[:after]
        return [nil, :before] if options[:before] && actual_date >= options[:before]

        [actual_date, nil]
      end

      private

      def parse(data)
        options[:format] ? Date.strptime(data, options[:format]) : Date.parse(data)
      end
    end
  end
end
