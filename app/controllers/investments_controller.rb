class InvestmentsController < ApplicationController
  before_action :set_investment

  def show
  end

  def adjusted_prices
    @prices = @investment.historical_prices.pluck(:date, 'close * adjustment').map do |p|
      { investment: @investment.symbol,
        date:       p[0],
        price:      p[1],
      }
    end

    respond_to do |format|
      format.json { render json: @prices }
    end
  end

  private
  def set_investment
    @investment = Investment.find_by(symbol: params[:id])
  end
end
