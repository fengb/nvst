class Investment < ActiveRecord::Base
  has_many :historical_prices, class_name: 'InvestmentHistoricalPrice'
  has_many :dividends,         class_name: 'InvestmentDividend'
  has_many :splits,            class_name: 'InvestmentSplit'

  def self.cash
    find_by(symbol: 'USD')
  end

  def self.benchmark
    find_by(symbol: 'SPY')
  end

  def title
    symbol
  end

  def price_matcher(start_date=nil)
    if start_date
      # start_date may not have a price entry.  We need to backtrack to find the real start date.
      start_date = historical_prices.where('date <= ?', start_date).last.date
      prices = historical_prices.where('date >= ?', start_date)
    else
      prices = historical_prices
    end

    BestMatchHash.new(prices.pluck('date', 'close'))
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
