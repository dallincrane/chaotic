# frozen_string_literal: true
module Chaotic
  module Filters
    Config = OpenStruct.new

    Config.any = OpenStruct.new(
      nils: true
    )

    Config.array = OpenStruct.new(
      nils: false,
      wrap: false
    )

    Config.boolean = OpenStruct.new(
      nils: false
    )

    Config.boolean = OpenStruct.new(
      nils: false,
      format: nil, # If nil, Date.parse will be used for coercion. If something like "%Y-%m-%d", Date.strptime is used
      after: nil,  # A date object, representing the minimum date allowed, inclusive
      before: nil, # A date object, representing the maximum date allowed, inclusive
      coercion_map: {
        'true' => true,
        'false' => false,
        '1' => true,
        '0' => false
      }.freeze
    )

    Config.decimal = OpenStruct.new(
      nils: false,
      delimiter: ', ',
      decimal_mark: '.',
      min: nil,
      max: nil,
      scale: nil
    )

    Config.duck = OpenStruct.new(
      nils: false,
      methods: nil
    )

    Config.file = OpenStruct.new(
      nils: false,
      upload: false,
      size: nil
    )

    Config.float = OpenStruct.new(
      nils: false,
      delimiter: ', ',
      decimal_mark: '.',
      min: nil,
      max: nil,
      scale: nil
    )

    Config.hash = OpenStruct.new(
      nils: false
    )

    Config.integer = OpenStruct.new(
      nils: false,
      delimiter: ', ',
      decimal_mark: '.',
      min: nil,
      max: nil,
      scale: nil,
      in: nil
    )

    Config.model = OpenStruct.new(
      nils: false,
      class: nil,
      new_records: false
    )

    Config.root = OpenStruct.new

    Config.string = OpenStruct.new(
      nils: false,
      allow_control_characters: false,
      strip: true,
      empty: false,
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
      nils: false,
      format: nil,
      after: nil,
      before: nil
    )

    def self.config
      yield Config
    end
  end
end
