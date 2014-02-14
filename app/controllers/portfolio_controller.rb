class PortfolioController < ApplicationController
  def index
  end

  def show
    @portfolio = PublicPortfolioPresenter.all(10000)
  end
end
