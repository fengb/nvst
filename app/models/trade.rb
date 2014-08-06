class Trade < ActiveRecord::Base
  include GenerateActivitiesWaterfall

  belongs_to :sell_investment, class_name: 'Investment'
  belongs_to :buy_investment,  class_name: 'Investment'
  has_and_belongs_to_many :activities

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
    buy_investment.is_a?(Investment::Cash)
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
    sell_value.to_r / raw_sell_value.to_r
  end

  def buy_adjustment
    buy_value.to_r / raw_buy_value.to_r
  end

  def raw_activities_data
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
