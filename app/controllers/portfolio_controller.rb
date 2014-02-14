class PortfolioController < ApplicationController
  def show
    @growth = PublicPortfolioPresenter.all(10000)
  end
end
