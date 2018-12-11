class PopulateInvestmentsJob < ApplicationJob
  def perform
    require 'stock_quote'

    Investment::Stock.find_each do |investment|
      Processor.new(investment).populate!
    end
  end

  def reset!
    SqlUtil.execute <<-END
      TRUNCATE investment_historical_prices RESTART IDENTITY CASCADE;
      TRUNCATE investment_splits RESTART IDENTITY CASCADE;
      TRUNCATE investment_dividends RESTART IDENTITY CASCADE;
    END
  end

  class Processor
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
      StockQuote::Stock.chart(@investment.symbol, '5y').chart do |row|
        next if row['date'] < target_date.to_s

        unadjustment = Rational(row["volume"], row["unadjustedVolume"])
        historical_prices.create!(date:  row['date'],
                                  high:  (unadjustment * row['high']).round(2),
                                  low:   (unadjustment * row['low']).round(2),
                                  close: (unadjustment * row['close']).round(2))
      end
    end

    def populate_splits!
      target_date = date_after(splits.maximum(:date))
      return if target_date > Date.current

      StockQuote::Stock.splits(@investment.symbol, '5y').splits do |row|
        split = splits.create!(date:   row['exDate'],
                               before: row['fromFactor'],
                               after:  row['toFactor'])
        adjust_prices_by(split)
      end
    end

    def populate_dividends!
      target_date = date_after(@investment.dividends.maximum(:ex_date))
      return if target_date > Date.current

      StockQuote::Stock.dividends(@investment.symbol, '5y').dividends do |row|
        dividend = dividends.create!(ex_date: row['exDate'],
                                     amount:  row['amount'].round(2))
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
