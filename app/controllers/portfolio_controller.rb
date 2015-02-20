class PortfolioController < ApplicationController
  self.allow_forgery_protection = false

  def index
    @portfolio = PublicPortfolioPresenter.all(10000)
  end

  def show
    @portfolio = PublicPortfolioPresenter.all(10000)
  end
end
