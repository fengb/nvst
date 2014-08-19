class Investment < ActiveRecord::Base
  has_many :historical_prices, class_name: 'InvestmentHistoricalPrice'
  has_many :dividends,         class_name: 'InvestmentDividend'
  has_many :splits,            class_name: 'InvestmentSplit'

  def self.benchmark
    find_by(symbol: 'SPY')
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

  def self.find_by_param(param)
    find_by(symbol: param)
  end

  def to_param
    symbol
  end

  rails_admin do
    object_label_method :symbol
  end

  class Stock < Investment
    validates :symbol, format: /\A[A-Z.]{1,4}[^X]?\z/
  end

  class MutualFund < Investment
    validates :symbol, format: /\A[A-Z]{4}X\z/
  end

  class Cash < Investment
    validates :symbol, format: /\A[A-Z]{3}\z/

    def price_matcher(start_date=nil)
      Hash.new(1)
    end

    def current_price
      1
    end

    def year_high
      1
    end

    def year_low
      1
    end
  end

  class Option < Investment
    SYMBOL_FORMAT = /\A([A-Z]{1,4})([0-9]{6})([CP])([0-9]{8})\z/
    validates :symbol, format: SYMBOL_FORMAT

    def underlying_symbol
      symbol_match[1]
    end

    def expiration_date
      Date.strptime(symbol_match[2], '%y%m%d')
    end

    def put?
      symbol_match[3] == 'P'
    end

    def call?
      symbol_match[3] == 'C'
    end

    def strike_price
      Rational(symbol_match[4], 1000)
    end

    def symbol_match
      SYMBOL_FORMAT.match(symbol)
    end
  end
end
