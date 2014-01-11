class Contribution < ActiveRecord::Base
  include GenerateTransactions

  belongs_to :user
  has_and_belongs_to_many :ownerships
  has_and_belongs_to_many :transactions

  def to_raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def generate_ownership!
    self.ownerships.create(user: user,
                           date: date,
                           units: Ownership.new_unit_per_amount_multiplier_at(date) * amount)
  end

  def self.value
    sum('amount')
  end

  def value
    amount
  end
end
