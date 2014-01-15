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

  def sell_value
    if buy_investment.cash?
      raw_sell_value - fee
    else
      raw_sell_value
    end
  end

  def buy_value
    if buy_investment.cash?
      raw_buy_value
    else
      raw_buy_value - fee
    end
  end

  def sell_price_fee_adjusted
    sell_value / sell_shares
  end

  def buy_price_fee_adjusted
    buy_value / buy_shares
  end

  def to_raw_transactions_data
    [{investment: sell_investment,
      date:       date,
      shares:     -sell_shares,
      price:      sell_price_fee_adjusted},
     {investment: buy_investment,
      date:       date,
      shares:     buy_shares,
      price:      buy_price_fee_adjusted}]
  end
end
