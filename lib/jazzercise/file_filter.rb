# frozen_string_literal: true
module Chaotic
  class FileFilter < AdditionalFilter
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

      if options[:size].is_a?(Fixnum)
        return [data, :size] if data.size > options[:size]
      end

      [data, nil]
    end
  end
end