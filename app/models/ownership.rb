class Ownership < ActiveRecord::Base
  belongs_to :user

  def self.total_at(date)
    where('date <= ?', date).sum(:units)
  end

  def self.new_unit_per_amount_multiplier_at(date)
    # Assume all contributions and expenses are incurred at once on the same day
    total_value = TransactionsGrowthPresenter.all.value_at(date) - Contribution.where(date: date).value + Expense.where(date: date).value
    return 1 if total_value == 0

    Ownership.total_at(date) / total_value
  end
end
