class PortfolioController < ApplicationController
  def benchmark
    @growth = BenchmarkGrowthPresenter.new(Investment.benchmark, contributions)
  end

  def principal
    @growth = BenchmarkGrowthPresenter.new(Investment.cash, contributions)
    render action: 'benchmark'
  end

  private
  def contributions
    Contribution.where('user_id != ?', 1)
  end
end
