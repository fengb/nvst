class PopulateInvestmentJob
  class << self
    def enqueue
      Investment.where(auto_update: true).pluck(:id).each do |id|
        self.perform(id)
      end
    end

    def perform(investment_id)
      Populate.run!(Investment.find(investment_id))
    end

    class Populate
      def initialize(investment)
        @investment = investment
      end

      def self.run!(investment)
        Populate.new(investment).run!
      end

      def latest_date
        @latest_date ||= InvestmentPrice.where(investment: @investment).order('date DESC').first.date
      end

      def run!
        prices!
        dividends!
        splits!
      end

      def prices!
        YahooFinance.historical_prices(investment.symbol).each do |row|
          return if row.date <= latest_date

          InvestmentPrice.create!(investment: investment,
                                  date:       row.date,
                                  high:       row.high,
                                  low:        row.low,
                                  close:      row.close)
        end
      end

      def dividends!
        YahooFinance.dividends(investment.symbol).each do |row|
          return if row.date <= latest_date

          InvestmentDividend.create!(investment: investment,
                                     date:       row.date,
                                     amount:     row.amount)
        end
      end

      def splits!
        YahooFinance.splits(investment.symbol).each do |row|
          return if row.date <= latest_date

          InvestmentDividend.create!(investment: investment,
                                     date:       row.date,
                                     before:     row.before,
                                     after:      row.after)
        end
      end
    end
  end
end
