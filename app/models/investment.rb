class Investment < ActiveRecord::Base
  has_many :historical_prices, class_name: 'InvestmentHistoricalPrice'
  has_many :dividends,         class_name: 'InvestmentDividend'
  has_many :splits,            class_name: 'InvestmentSplit'

  def self.cash
    find_by(auto_update: false)
  end

  def title
    symbol
  end

  def price_matcher
    BestMatchHash.new(historical_prices.pluck('date', 'close'))
  end

  def current_price
    historical_prices.last.close
  end

  def year_high
    historical_prices.year_range.maximum(:high)
  end

  def year_low
    historical_prices.year_range.minimum(:low)
  end
end
