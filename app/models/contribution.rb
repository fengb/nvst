class Contribution < ActiveRecord::Base
  include GenerateTransactions

  belongs_to :user
  has_and_belongs_to_many :transactions

  def to_raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def calculate_units!
    self.units = calculate_units
    self.save!
  end

  def calculate_units
    # Assume all contributions and expenses are incurred at once on the same day
    total_value = TransactionsGrowthPresenter.all.value_at(date) - Contribution.where(date: date).value + Expense.where(date: date).value
    return amount if total_value == 0

    total_units = Contribution.where('date < ?', date).sum(:units)
    total_units / total_value * amount
  end

  def self.value
    sum('amount')
  end

  def value
    amount
  end
end
