class PopulateInvestmentsJob < ApplicationJob
  def perform
    require 'yahoo_finance'

    Investment::Stock.find_each do |investment|
      begin
        Processor.new(investment).populate!
      rescue OpenURI::HTTPError => e
        $stderr.puts e
      end
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
        $stderr.puts "#{@investment.symbol}: #{target_date}"
        populate_historical_prices!
        populate_splits!
        populate_dividends!
      end
    end

    def populate_historical_prices!
      request['prices'].each do |row|
        date = Time.at(row['date']).to_date
        return if date < target_date[:prices]
        # splits / dividends are in 'prices' for some reason
        next unless row['type'].nil?

        historical_prices.create!(date:  date,
                                  high:  row['high'].to_d.round(4),
                                  low:   row['low'].to_d.round(4),
                                  close: row['close'].to_d.round(4))
      end
    end

    def populate_splits!
      request['eventsData'].each do |row|
        date = Time.at(row['date']).to_date
        return if date < target_date[:splits]
        next unless row['type'] == 'SPLIT'
        # Yahoo shows 1:1 splits... wtf
        next if row['numerator'] == row['denominator']
        # TODO: find a better source -- this is a spinoff
        next if row['denominator'].to_i > 100

        split = splits.create!(date:   date,
                               before: row['denominator'].to_i,
                               after:  row['numerator'].to_i)
        adjust_prices_by(split)
      end
    end

    def populate_dividends!
      request['eventsData'].each do |row|
        date = Time.at(row['date']).to_date
        return if date < target_date[:dividends]
        next unless row['type'] == 'DIVIDEND'

        dividend = dividends.create!(ex_date: date,
                                     amount:  row['amount'].to_d.round(4))
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

    def target_date
      @target_date ||= {
        prices: date_after(historical_prices.maximum(:date)),
        dividends: date_after(dividends.maximum(:ex_date)),
        splits: date_after(splits.maximum(:date)),
      }
    end

    def request
      @request ||= YahooFinance.history(@investment.symbol, start_date: target_date.values.min)
    end
  end
end
