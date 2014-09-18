class PortfolioController < ApplicationController
  self.allow_forgery_protection = false

  def index
  end

  def show
    @portfolio = PublicPortfolioPresenter.all(10000)
  end
end
