class Trade < ActiveRecord::Base
  include GenerateTransactions

  belongs_to :sell_investment, class_name: 'Investment'
  belongs_to :buy_investment,  class_name: 'Investment'
  has_and_belongs_to_many :transactions

  def sell_value
    sell_shares * sell_price
  end

  def buy_value
    buy_shares * buy_price
  end

  def fee
    sell_value - buy_value
  end

  def to_raw_transactions_data
    [{investment: sell_investment,
      date:       date,
      shares:     -sell_shares,
      price:      sell_price},
     {investment: buy_investment,
      date:       date,
      shares:     buy_shares,
      price:      buy_price}]
  end
end
