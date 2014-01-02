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
    self.build_ownership(units: calculate_units, date: date, user: user)
    self.save!
  end

  def calculate_units
    # Assume all contributions and expenses are incurred at once on the same day
    total_value = TransactionsGrowthPresenter.all.value_at(date) - Contribution.where(date: date).value + Expense.where(date: date).value
    return amount if total_value == 0

    Ownership.total_at(date) / total_value * amount
  end

  def self.value
    sum('amount')
  end

  def value
    amount
  end
end
