# frozen_string_literal: true
module Chaotic
  module Concerns
    module Filterable
      extend ActiveSupport::Concern

      included do
        attr_reader :default_options
        attr_accessor :options
      end

      def initialize(name = nil, opts = {}, &block)
        @params = {}
        @name = name

        default_options = self.class.instance_variable_get(:@default_options)
        self.class.instance_variable_set(:@options, default_options.merge(opts))

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
