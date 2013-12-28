class Investment < ActiveRecord::Base
  has_many :prices, class_name: 'InvestmentPrice'

  def current_price
    prices.order('date').last.close
  end

  def year_high
    prices.year_range.maximum(:high)
  end

  def year_low
    prices.year_range.minimum(:low)
  end
end
