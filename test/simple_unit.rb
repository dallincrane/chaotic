# frozen_string_literal: true

class SimpleUnit
  include Objective::Unit

  filter do
    string :name, max: 10
    string :email
    integer :amount, nils: ALLOW
  end

  def validate
    return if email.include?('@')
    add_error(:email, :invalid, 'Email must contain @')
  end

  def execute
  end
end
