class BenchmarkPresenter
  def initialize(investment)
    contributions = Contribution.order(:date)
    @price_matcher = investment.price_matcher(contributions.first.date)
    @share_matcher = BestMatchHash.sum(contributions.map{|c| [c.date, c.amount / @price_matcher[c.date]]})
  end

  def dates
    @price_matcher.keys
  end

  def value_at(date)
    @price_matcher[date] * @share_matcher[date]
  end
end
