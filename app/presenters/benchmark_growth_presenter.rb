class BenchmarkGrowthPresenter
  def initialize(investment, contributions)
    @contributions = contributions
    @price_matcher = investment.price_matcher(contributions.first.date)
    @share_matcher = BestMatchHash.sum(contributions.map{|c| [c.date, c.amount / @price_matcher[c.date]]})
  end

  def dates
    # FIXME: defuglify
    @dates ||= Investment.benchmark.price_matcher(@contributions.first.date).keys
  end

  def value_at(date)
    @price_matcher[date] * @share_matcher[date]
  end
end
