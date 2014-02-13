class PortfolioController < ApplicationController
  def index
  end

  def benchmark
    @growth = PublicPortfolioPresenter.all(10000)
  end

  private
  def contributions
    Contribution.where('user_id != ?', 1)
  end
end
