class Contribution < ActiveRecord::Base
  include GenerateTransactions

  belongs_to :user
  belongs_to :ownership
  has_and_belongs_to_many :transactions

  def to_raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def generate_ownership!
    self.build_ownership(user: user,
                         date: date,
                         units: Ownership.new_unit_per_amount_multiplier_at(date) * amount)
    self.save!
  end

  def self.value
    sum('amount')
  end

  def value
    amount
  end
end
