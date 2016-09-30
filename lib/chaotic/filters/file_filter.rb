# frozen_string_literal: true
module Chaotic
  module Filters
    class FileFilter
      include Chaotic::Concerns::Filterable

      @default_options = {
        nils: false,
        upload: false,
        size: nil
      }

      def filter(data)
        if data.nil?
          return [data, nil] if options[:nils]
          return [data, :nils]
        end

        return [data, :empty] if data == ''

        methods = [:read, :size]
        methods.concat([:original_filename, :content_type]) if options[:upload]
        methods.each do |method|
          return [data, :file] unless data.respond_to?(method)
        end

        return [data, :size] if options[:size] && data.size > options[:size]

        [data, nil]
      end
    end
  end
end
