require 'yahoo_finance'


class PopulateInvestmentsJob
  def self.perform
    Investment::Stock.find_each do |investment|
      self.new(investment).populate!
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

  def populate!
    ActiveRecord::Base.transaction do
      populate_historical_prices!
      populate_splits!
      populate_dividends!
    end
  end

  def populate_historical_prices!
    latest_date = historical_prices.maximum(:date) || Date.new(1900)
    return if latest_date + 1 >= Date.current

    YahooFinance.historical_quotes(@investment.symbol, start_date: latest_date + 1).each do |row|
      historical_prices.create!(date:  row.trade_date,
                                high:  row.high,
                                low:   row.low,
                                close: row.close)
    end
  end

  def populate_splits!
    latest_date = @investment.splits.maximum(:date) || Date.new(1900)
    return if latest_date + 1 >= Date.current

    YahooFinance.splits(@investment.symbol, start_date: latest_date + 1).each do |row|
      split = splits.create!(date:   row.date,
                             before: row.before,
                             after:  row.after)
      adjust_prices_by(split)
    end
  end

  def populate_dividends!
    latest_date = @investment.dividends.maximum(:ex_date) || Date.new(1900)
    return if latest_date + 1 >= Date.current

    YahooFinance.dividends(@investment.symbol, start_date: latest_date + 1).each do |row|
      # Yahoo dividends are adjusted so we need to unadjust them
      amount = row.yield.to_d * split_unadjustment(row.date.to_date)
      dividend = dividends.create!(ex_date: row.date,
                                   amount:  amount.round(2))
      adjust_prices_by(dividend)
    end
  end

  def historical_prices
    @investment.historical_prices
  end

  def dividends
    @investment.dividends
  end

  def splits
    @investment.splits
  end

  def split_unadjustment(date)
    splits.select{|s| s.date >= date}.map(&:shares_adjustment).inject(1, :*)
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
