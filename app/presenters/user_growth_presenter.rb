require 'best_match_hash'


class UserGrowthPresenter
  def initialize(user)
    @transactions_growth = TransactionsGrowthPresenter.all
    @contributions = user.contributions.order(:date)
    @ownerships = user.ownerships.order(:date)
  end

  def gross_value_at(date)
    units_matcher[date] / total_units * @transactions_growth.value_at(date)
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
  def total_units
    @total_units ||= Contribution.sum(:units)
  end

  def units_matcher
    @units_matcher ||= BestMatchHash.sum(@ownerships.map{|c| [c.date, c.units]})
  end

  def benchmark_shares_matcher
    @benchmark_shares_matcher ||= BestMatchHash.sum(@contributions.map{|c| [c.date, c.amount / benchmark_price_matcher[c.date]]})
  end

  def benchmark_price_matcher
    @benchmark_price_matcher ||= Investment.benchmark.price_matcher(@ownerships.first.date)
  end
end
