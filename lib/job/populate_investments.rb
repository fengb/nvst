require 'yahoo_finance'


module Job
  class PopulateInvestments
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
      target_date = date_after(historical_prices.maximum(:date))
      return if target_date > Date.current

      $stderr.puts "#{@investment.symbol}: #{target_date}"
      YahooFinance.historical_quotes(@investment.symbol, start_date: target_date).each do |row|
        historical_prices.create!(date:  row.trade_date,
                                  high:  row.high,
                                  low:   row.low,
                                  close: row.close)
      end
    end

    def populate_splits!
      target_date = date_after(splits.maximum(:date))
      return if target_date > Date.current

      YahooFinance.splits(@investment.symbol, start_date: target_date).each do |row|
        split = splits.create!(date:   row.date,
                               before: row.before,
                               after:  row.after)
        adjust_prices_by(split)
      end
    end

    def populate_dividends!
      # FIXME: better source for dividend data
      target_date = date_after(@investment.dividends.maximum(:ex_date))
      return if target_date > Date.current

      YahooFinance.historical_quotes(@investment.symbol, period: :dividends_only, start_date: target_date).each do |row|
        # Yahoo dividends are adjusted so we need to unadjust them
        date = row.dividend_pay_date.to_date
        amount = row.dividend_yield.to_d * split_unadjustment(date)
        dividend = dividends.create!(ex_date: date,
                                     amount:  amount.round(2))
        adjust_prices_by(dividend)
      end
    end

    def date_after(date, default = Date.new(1900))
      date ? date + 1 : default
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
      historical_prices.where('date <= ?', instance.price_adjust_up_to_date).
                        update_all(['adjustment = adjustment * ?', instance.price_adjustment])
    end
  end
end
