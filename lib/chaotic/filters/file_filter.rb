# frozen_string_literal: true
module Chaotic
  module Filters
    class FileFilter < Chaotic::Filter
      default_options(
        nils: false,
        upload: false,
        size: nil
      )

      def feed(given)
        return handle_nil if given.nil?

        coerced = coerce(given)
        return [given, :file] unless respond_to_all?(coerced)

        error = validate(coerced)
        return [coerced, error] if error

        [coerced, nil]
      end

      def coerce(given)
        given
      end

      def respond_to_all?(coerced)
        methods = %i(read size)
        methods.concat(%i(original_filename content_type)) if options.upload
        methods.map { |method| coerced.respond_to?(method) }.all?
      end

      def validate(coerced)
        return :size if options.size && coerced.size > options.size
      end
    end
  end
end
