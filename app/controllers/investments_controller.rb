class InvestmentsController < ApplicationController
  before_action :set_investment

  def show
  end

  def prices
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : end_date - 365
    @prices = @investment.historical_prices.where(date: start_date..end_date).reverse_order

    respond_to do |format|
      format.html
      format.json
    end
  end

  def benchmark
    @benchmark = BenchmarkPresenter.new(@investment)
  end

  private
  def set_investment
    @investment = Investment.find_by_param(params[:id])
  end
end
