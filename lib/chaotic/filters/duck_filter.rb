# frozen_string_literal: true
module Chaotic
  module Filters
    class DuckFilter < Chaotic::Filter
      default_options(
        nils: false,
        methods: nil
      )

      # def feed(data)
      #   return handle_nil if data.nil?
      #
      #   Array.wrap(options[:methods]).each do |method|
      #     return [data, :duck] unless data.respond_to?(method)
      #   end
      #
      #   [data, nil]
      # end

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)
        return [given, :duck] unless respond_to_all?(coerced)

        [coerced, nil]
      end

      def coerce(given)
        given
      end

      def respond_to_all?(coerced)
        Array.wrap(options[:methods]).map do |method|
          coerced.respond_to?(method)
        end.all?
      end
    end
  end
end
