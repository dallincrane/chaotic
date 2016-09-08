# frozen_string_literal: true
module Chaotic
  module Concerns
    module Filterable
      extend ActiveSupport::Concern

      attr_reader :default_options
      attr_accessor :options

      def initialize(name, opts = {}, &block)
        @params = {}

        @name = name
        self.options = default_options.merge(opts)

        try(:run_block, &block)
      end

      def required?
        options[:required] || true
      end

      def optional?
        !required?
      end

      def default?
        options.key?(:default)
      end

      def default
        options[:default]
      end
    end
  end
end
