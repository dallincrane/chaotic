# frozen_string_literal: true
module Chaotic
  class TimeFilter < AdditionalFilter
    @default_options = {
      nils: false,
      format: nil,
      after: nil,
      before: nil
    }

    def filter(data)
      if data.nil?
        return [data, nil] if options[:nils]
        return [data, :nils]
      end

      return [data, :empty] if '' == data

      if data.is_a?(Time) # Time
        actual_time = data
      elsif data.is_a?(String)
        begin
          actual_time = if options[:format]
                          Time.strptime(data, options[:format])
                        else
                          Time.parse(data)
                        end
        rescue ArgumentError
          return [nil, :time]
        end
      elsif data.respond_to?(:to_time) # Date, DateTime
        actual_time = data.to_time
      else
        return [nil, :time]
      end

      return [nil, :after] if options[:after] && actual_time <= options[:after]
      return [nil, :before] if options[:before] && actual_time >= options[:before]

      [actual_time, nil]
    end
  end
end
