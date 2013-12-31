class Contribution < ActiveRecord::Base
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
    total_value = TransactionsGrowthPresenter.all.value_at(date)
    return amount if total_value == 0

    total_units = Contribution.where('date < ?', date).sum(:units)
    total_units / total_value * amount
  end
end
