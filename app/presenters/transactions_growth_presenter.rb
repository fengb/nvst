require 'best_match_hash'


class TransactionsGrowthPresenter
  def self.all
    self.new(Transaction.includes(lot: :investment))
  end

  def initialize(transactions)
    @price_matchers = {}
    @shares_matchers = {}
    transactions.group_by(&:investment).each do |inv, transactions|
      shares_by_date = {}
      total_shares = 0
      transactions.sort_by(&:date).each do |transaction|
        total_shares += transaction.shares
        shares_by_date[transaction.date] = total_shares
      end
      @shares_matchers[inv] = BestMatchHash.new(shares_by_date, 0)
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
    price_matcher(investment)[date]
  end

  def shares_for(investment, date)
    @shares_matchers[investment][date]
  end

  private
  def investments
    @shares_matchers.keys
  end

  def price_matcher(investment)
    @price_matchers[investment] ||= investment.price_matcher(first_date_for(investment))
  end

  def first_date_for(investment)
    @shares_matchers[investment].keys.first
  end
end
