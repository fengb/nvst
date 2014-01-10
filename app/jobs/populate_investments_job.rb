require 'yahoo_finance'


class PopulateInvestmentsJob
  class << self
    def perform
      Investment.auto_update.each do |investment|
        self.new(investment).run!
      end
    end
  end

  def initialize(investment)
    @investment = investment
  end

  def run!
    ActiveRecord::Base.transaction do
      dividends!
      splits!
      historical_prices!
    end
  end

  def dividends!
    YahooFinance.dividends(@investment.symbol).each do |row|
      return if row.date <= latest_date

      InvestmentDividend.create!(investment: @investment,
                                 date:       row.date,
                                 amount:     row.amount)
    end
  end

  def splits!
    YahooFinance.splits(@investment.symbol).each do |row|
      return if row.date <= latest_date

      InvestmentSplit.create!(investment: @investment,
                              date:       row.date,
                              before:     row.before,
                              after:      row.after)
    end
  end

  def historical_prices!
    raw_adjustment = latest_historical_price.try(:raw_adjustment) || 1.0
    splits = existing_hash_by_date(InvestmentSplit)
    dividends = existing_hash_by_date(InvestmentDividend)

    YahooFinance.historical_prices(@investment.symbol, start_date: latest_date + 1).reverse.each do |row|
      if split = splits[row.date]
        raw_adjustment *= split.after.to_f / split.before.to_f
      end
      if dividend = dividends[row.date]
        raw_adjustment *= (dividend.amount.to_f + row.close.to_f) / row.close.to_f
      end

      InvestmentHistoricalPrice.create!(investment:     @investment,
                                        date:           row.date,
                                        high:           row.high,
                                        low:            row.low,
                                        close:          row.close,
                                        raw_adjustment: raw_adjustment)
    end
  end

  private
  def latest_historical_price
    @price ||= InvestmentHistoricalPrice.where(investment: @investment).last
  end

  def latest_date
    @latest_date ||= latest_historical_price.try(:date) || Date.new(1900)
  end

  def existing_hash_by_date(model)
    Hash[model.where(investment: @investment).map{|r| [r.date, r]}]
  end
end
