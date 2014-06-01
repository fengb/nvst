require 'yahoo_finance'


class PopulateInvestmentsJob
  class << self
    def perform
      Investment.includes(:historical_prices)
                .where(category: 'cash', investment_historical_prices: {investment_id: nil}).each do |investment|
        investment.historical_prices.create!(date: '1900-01-01', high: 1, low: 1, close: 1, adjustment: 1)
      end

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
      historical_prices!
      dividends!
      splits!
    end
  end

  def historical_prices!
    latest_date = InvestmentHistoricalPrice.where(investment: @investment).last.try(:date) || Date.new(1900)
    YahooFinance.historical_prices(@investment.symbol, start_date: latest_date + 1).reverse.each do |row|
      InvestmentHistoricalPrice.create!(investment:     @investment,
                                        date:           row.date,
                                        high:           row.high,
                                        low:            row.low,
                                        close:          row.close,
                                        adjustment:     1.0)
    end
  end

  def dividends!
    latest_date = InvestmentDividend.where(investment: @investment).last.try(:ex_date) || Date.new(1900)
    YahooFinance.dividends(@investment.symbol).each do |row|
      return if row.date <= latest_date

      dividend = InvestmentDividend.create!(investment: @investment,
                                            ex_date:    row.date,
                                            amount:     row.amount)
      adjust_prices_by(dividend)
    end
  end

  def splits!
    latest_date = InvestmentSplit.where(investment: @investment).last.try(:date) || Date.new(1900)
    YahooFinance.splits(@investment.symbol).each do |row|
      return if row.date <= latest_date

      split = InvestmentSplit.create!(investment: @investment,
                                      date:       row.date,
                                      before:     row.before,
                                      after:      row.after)
      adjust_prices_by(split)
    end
  end

  private
  def adjust_prices_by(instance)
    # instance needs to implement #investment_id, #adjust_through_date, and #adjustment
      sql = ActiveRecord::Base.send(:sanitize_sql_array, [<<-SQL, instance.price_adjustment, instance.investment_id, instance.price_adjust_up_to_date])
        UPDATE #{InvestmentHistoricalPrice.table_name}
           SET adjustment = adjustment * ?
         WHERE investment_id = ?
           AND date <= ?
      SQL
      ActiveRecord::Base.connection.execute sql
  end
end
