class PortfolioController < ApplicationController
  def index
    @ignore_csrf = true
  end

  def show
    @portfolio = PublicPortfolioPresenter.all(10000)
  end
end
