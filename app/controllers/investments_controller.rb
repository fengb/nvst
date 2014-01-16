class InvestmentsController < ApplicationController
  before_action :set_investment

  def show
  end

  def prices
    @prices = @investment.historical_prices.pluck(:date, :close, 'close * adjustment').map do |p|
      { investment:     @investment.symbol,
        date:           p[0],
        close:          p[1],
        adjusted_close: p[2],
      }
    end

    respond_to do |format|
      format.json { render json: @prices }
    end
  end

  private
  def set_investment
    @investment = Investment.find_by_param(params[:id])
  end
end
