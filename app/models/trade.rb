class Trade < ActiveRecord::Base
  belongs_to :sell_investment, class_name: 'Investment'
  belongs_to :buy_investment,  class_name: 'Investment'

  def sell_value
    sell_shares * sell_price
  end

  def buy_value
    buy_shares * buy_price
  end

  def fee
    sell_value - buy_value
  end
end
