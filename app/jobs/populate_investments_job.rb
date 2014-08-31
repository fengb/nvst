require 'yahoo_finance'


class PopulateInvestmentsJob
  def self.perform
    Investment::Stock.find_each do |investment|
      self.new(investment).stock!
    end
  end

  def self.reset!
    SqlUtil.execute <<-END
      TRUNCATE investment_historical_prices RESTART IDENTITY CASCADE;
      TRUNCATE investment_splits RESTART IDENTITY CASCADE;
      TRUNCATE investment_dividends RESTART IDENTITY CASCADE;
    END
  end

  def initialize(investment)
    @investment = investment
  end

  def stock!
    ActiveRecord::Base.transaction do
      historical_prices!
      splits!
      dividends!
    end
  end

  def historical_prices!
    latest_date = InvestmentHistoricalPrice.where(investment: @investment).last.try(:date) || Date.new(1900)
    return if latest_date + 1 >= Date.current

    YahooFinance.historical_quotes(@investment.symbol, start_date: latest_date + 1).reverse.each do |row|
      InvestmentHistoricalPrice.create!(investment: @investment,
                                        date:       row.trade_date,
                                        high:       row.high,
                                        low:        row.low,
                                        close:      row.close)
    end
  end

  def splits!
    latest_date = InvestmentSplit.where(investment: @investment).last.try(:date) || Date.new(1900)
    return if latest_date + 1 >= Date.current

    YahooFinance.splits(@investment.symbol).each do |row|
      return if row.date <= latest_date

      split = InvestmentSplit.create!(investment: @investment,
                                      date:       row.date,
                                      before:     row.before,
                                      after:      row.after)
      adjust_prices_by(split)
    end
  end

  def dividends!
    latest_date = InvestmentDividend.where(investment: @investment).last.try(:ex_date) || Date.new(1900)
    return if latest_date + 1 >= Date.current

    YahooFinance.dividends(@investment.symbol, start_date: latest_date + 1).each do |row|
      amount = row.yield.to_d * split_unadjustment(row.date)
      dividend = InvestmentDividend.create!(investment: @investment,
                                            ex_date:    row.date,
                                            amount:     amount.round(2))
      adjust_prices_by(dividend)
    end
  end

  def split_unadjustment(date)
    InvestmentSplit.where(investment: @investment).price_unadjustment(on: date)
  end

  private
  def adjust_prices_by(instance)
    # instance needs to implement #investment_id, #adjust_through_date, and #adjustment
    SqlUtil.execute <<-SQL, instance.price_adjustment, instance.investment_id, instance.price_adjust_up_to_date
      UPDATE #{InvestmentHistoricalPrice.table_name}
         SET adjustment = adjustment * ?
       WHERE investment_id = ?
         AND date <= ?
    SQL
  end
end
