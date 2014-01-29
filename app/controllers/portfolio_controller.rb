class PortfolioController < ApplicationController
  def index
  end

  def benchmark
    @growth = BenchmarkGrowthPresenter.new(Investment.benchmark, contributions, normalize_to: 10000)
  end

  def principal
    @growth = BenchmarkGrowthPresenter.new(Investment.cash, contributions, normalize_to: 10000)
    render action: 'benchmark'
  end

  private
  def contributions
    Contribution.where('user_id != ?', 1)
  end
end
