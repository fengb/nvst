class InvestmentsController < ApplicationController
  before_action :set_investment

  def show
  end

  def prices
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : end_date - 365
    @prices = @investment.historical_prices.where(date: start_date..end_date).pluck(:date, :close, 'close * adjustment').map do |p|
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
