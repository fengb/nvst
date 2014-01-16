class InvestmentsController < ApplicationController
  before_action :set_investment

  def show
  end

  private
  def set_investment
    @investment = Investment.find_by(symbol: params[:id])
  end
end
