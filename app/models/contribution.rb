class Contribution < ActiveRecord::Base
  include GenerateTransactions
  include GenerateOwnerships

  belongs_to :user
  has_and_belongs_to_many :ownerships
  has_and_belongs_to_many :transactions

  def self.value
    sum('amount')
  end

  def raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def raw_ownerships_data
    [{user: user,
      date: date,
      units: amount * Ownership.new_unit_per_amount_multiplier_at(date)}]
  end

  def cashflow_amount
    amount
  end

  def value
    amount
  end
end
