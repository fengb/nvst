require 'best_match_hash'


class PortfolioPresenter
  def initialize(transactions)
    @shares_lookups = {}
    transactions.group_by(&:investment).each do |inv, transactions|
      shares_by_date = {}
      total_shares = 0
      transactions.sort_by(&:date).each do |transaction|
        total_shares += transaction.shares
        shares_by_date[transaction.date] = total_shares
      end
      @shares_lookups[inv] = BestMatchHash.new(shares_by_date, 0)
    end
  end

  def value_at(date)
    investments.map{|i| value_for(i, date)}.sum
  end

  def value_for(investment, date)
    shares = shares_for(investment, date)
    shares.zero? ? 0 : shares * price_for(investment, date)
  end

  def price_for(investment, date)
  end

  def shares_for(investment, date)
    @shares_lookups[investment][date]
  end

  private
  def investments
    @shares_lookups.keys
  end
end
