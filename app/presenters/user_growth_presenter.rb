class UserGrowthPresenter
  def initialize(user)
    @user = user
    @portfolio = PortfolioPresenter.all
    @contributions = user.contributions.order(:date)
    @ownership = OwnershipPresenter.all
  end

  def gross_value_at(date)
    @ownership.user_percent(@user, date) * @portfolio.value_at(date)
  end

  def benchmark_value_at(date)
    benchmark_shares_matcher[date] * benchmark_price_matcher[date]
  end

  def unbooked_fee_at(date)
    (gross_value_at(date) - benchmark_value_at(date)) / 2
  end

  def value_at(date)
    gross_value_at(date) - unbooked_fee_at(date)
  end

  private
  def benchmark_shares_matcher
    @benchmark_shares_matcher ||= BestMatchHash.sum(@contributions.map{|c| [c.date, c.amount / benchmark_price_matcher[c.date]]})
  end

  def benchmark_price_matcher
    @benchmark_price_matcher ||= Investment.benchmark.price_matcher(@contributions.first.date)
  end
end
