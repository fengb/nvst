class Investment < ActiveRecord::Base
  has_many :historical_prices, class_name: 'InvestmentHistoricalPrice'
  has_many :dividends,         class_name: 'InvestmentDividend'
  has_many :splits,            class_name: 'InvestmentSplit'

  validates :symbol, presence: true, uniqueness: true
  validates :name,   presence: true

  def self.benchmark
    @benchmark ||= find_by(symbol: 'SPY')
  end

  def self.lookup_by_symbol(&block)
    lookup = Hash.new do |hash, key|
      hash[key] = block.call(key)
    end

    all.each do |investment|
      lookup[investment.symbol] = investment
      investment.past_symbols.each do |symbol|
        lookup[symbol] = investment
      end
    end

    lookup
  end

  def price_matcher(start_date=nil)
    if start_date
      # start_date may not have a price entry.  We need to backtrack to find the real start date.
      start_date_sql = historical_prices.select('MAX(date)').where('date <= ?', start_date).to_sql
      prices = historical_prices.where("date >= (#{start_date_sql})")
    else
      prices = historical_prices
    end

    BestMatchHash.new(prices.order('date').pluck('date', 'close'))
  end

  def current_price
    historical_prices.order('date DESC').first.close
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

  def to_s
    symbol
  end

  class Stock < Investment
    validates :symbol, format: /\A[A-Z.]{1,4}[^X]?\z/
  end

  class MutualFund < Investment
    validates :symbol, format: /\A[A-Z]{4}X\z/
  end

  class Cash < Investment
    validates :symbol, format: /\A[A-Z]{3}\z/

    def self.default
      @default ||= first
    end

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
