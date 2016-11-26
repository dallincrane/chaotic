# frozen_string_literal: true
module Chaotic
  module Filters
    class BooleanFilter < Chaotic::Filter
      default_options(
        nils: false
      )

      def feed(data)
        if data.nil?
          return [data, nil] if options.nils
          return [data, :nils]
        end

        return [data, :empty] if data == ''

        return [data, nil] if data == true || data == false

        data = data.to_s if data.is_a?(Integer)

        if data.is_a?(String)
          res = Chaotic.boolean_map[data.downcase]
          return [res, nil] unless res.nil?
        end

        [data, :boolean]
      end
    end
  end
end
