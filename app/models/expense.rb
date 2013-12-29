class Expense < ActiveRecord::Base
  has_and_belongs_to_many :transactions

  def to_raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     -amount,
      price:      1}]
  end
end
