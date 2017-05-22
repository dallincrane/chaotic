# frozen_string_literal: true
module Objective
  module Filters
    Config = OpenStruct.new

    Config.any = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::ALLOW,
      invalid: Objective::DENY,
      strict: false
    )

    Config.array = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      wrap: false
    )

    Config.boolean = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      coercion_map: {
        'true' => true,
        'false' => false,
        '1' => true,
        '0' => false
      }.freeze
    )

    Config.date = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      format: nil,
      after: nil,
      before: nil
    )

    Config.decimal = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      delimiter: ', ',
      decimal_mark: '.',
      min: nil,
      max: nil,
      scale: nil
    )

    Config.duck = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      methods: nil
    )

    Config.file = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      upload: false,
      size: nil
    )

    Config.float = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      delimiter: ', ',
      decimal_mark: '.',
      min: nil,
      max: nil,
      scale: nil
    )

    Config.hash = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false
    )

    Config.integer = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      delimiter: ', ',
      decimal_mark: '.',
      min: nil,
      max: nil,
      scale: nil,
      in: nil
    )

    Config.model = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      class: nil,
      new_records: false
    )

    Config.root = OpenStruct.new

    Config.string = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      allow_control_characters: false,
      strip: true,
      empty: Objective::DENY,
      min: nil,
      max: nil,
      in: nil,
      matches: nil,
      decimal_format: 'F',
      coercable_classes: [
        Symbol,
        TrueClass,
        FalseClass,
        Integer,
        Float,
        BigDecimal
      ].freeze
    )

    Config.time = OpenStruct.new(
      none: Objective::DENY,
      nils: Objective::DENY,
      invalid: Objective::DENY,
      strict: false,
      format: nil,
      after: nil,
      before: nil
    )

    def self.config
      yield Config
    end
  end
end
