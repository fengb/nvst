class Admin::PortfolioController < Admin::BaseController
  def show
    @position_summaries = PositionSummaryPresenter.all
  end

  def growth
    @portfolio = PortfolioPresenter.all
  end

  def transactions
    @transactions = [Contribution.all, Event.all, Expense.all, Trade.all].flatten
    @transactions.sort_by!(&:date).reverse!
  end
end
