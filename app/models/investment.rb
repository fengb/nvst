class Investment < ApplicationRecord
  has_many :historical_prices, class_name: 'InvestmentHistoricalPrice'
  has_many :year_prices, ->{ year_range }, class_name: 'InvestmentHistoricalPrice'
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

  def current_price
    year_prices.max_by(&:date).close
  end

  def year_high
    year_prices.map(&:high).max
  end

  def year_low
    year_prices.map(&:low).min
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
    SYMBOL_FORMAT = /\A(?<root>[A-Z]{1,4})(?<date>[0-9]{6})(?<type>[CP])(?<strike>[0-9]{8})\z/
    validates :symbol, format: SYMBOL_FORMAT

    def underlying_symbol
      symbol_match[:root]
    end

    def expiration_date
      Date.strptime(symbol_match[:date], '%y%m%d')
    end

    def put?
      symbol_match[:type] == 'P'
    end

    def call?
      symbol_match[:type] == 'C'
    end

    def strike_price
      Rational(symbol_match[:strike], 1000)
    end

    def symbol_match
      SYMBOL_FORMAT.match(symbol)
    end
  end
end
