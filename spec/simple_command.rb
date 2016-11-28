# frozen_string_literal: true
class SimpleCommand
  include Chaotic::Command

  filter do
    string :name, max: 10
    string :email
    integer :amount, discard_nils: true
  end

  def validate
    return if email&.include?('@')
    add_error(:email, :invalid, 'Email must contain @')
  end

  def execute
  end
end
