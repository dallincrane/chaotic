# frozen_string_literal: true
class SimpleCommand
  include Chaotic::Command

  filter do
    string :name, max_length: 10
    string :email
    integer :amount, required: false
  end

  def validate
    return if email&.include?('@')
    add_error(:email, :invalid, 'Email must contain @')
  end

  def execute
  end
end
