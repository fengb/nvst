class PortfolioController < ApplicationController
  def show
    @growth = PublicPortfolioPresenter.all(10000)
  end

  private
  def contributions
    Contribution.where('user_id != ?', 1)
  end
end
