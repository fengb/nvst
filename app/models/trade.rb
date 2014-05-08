class Trade < ActiveRecord::Base
  include GenerateTransactions

  belongs_to :sell_investment, class_name: 'Investment'
  belongs_to :buy_investment,  class_name: 'Investment'
  has_and_belongs_to_many :transactions

  def raw_sell_value
    sell_shares * sell_price
  end

  def raw_buy_value
    buy_shares * buy_price
  end

  def fee
    raw_sell_value - raw_buy_value
  end

  def adjust_sell?
    buy_investment.cash?
  end

  def sell_value
    if adjust_sell?
      raw_buy_value
    else
      raw_sell_value
    end
  end

  def buy_value
    if adjust_sell?
      raw_buy_value
    else
      raw_sell_value
    end
  end

  def sell_adjustment
    Rational(sell_value, raw_sell_value)
  end

  def buy_adjustment
    Rational(buy_value, raw_buy_value)
  end

  def raw_transactions_data
    [{investment: sell_investment,
      date:       date,
      shares:     -sell_shares,
      price:      sell_price,
      adjustment: sell_adjustment},
     {investment: buy_investment,
      date:       date,
      shares:     buy_shares,
      price:      buy_price,
      adjustment: buy_adjustment}]
  end
end
