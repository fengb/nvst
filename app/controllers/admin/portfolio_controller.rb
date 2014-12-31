class Admin::PortfolioController < Admin::BaseController
  def show
    @position_summaries = PositionSummaryPresenter.all
  end

  def growth
    @portfolio = PortfolioPresenter.all
  end

  def update
    csv_io = params[:csv]
    created = Schwab.process!(csv_io.read)
    if created.present?
      require 'job/generate_activities'
      Job::GenerateActivities.perform
    end

    redirect_to action: 'show'
  end

  def transactions
    @transactions = [Contribution.all, Event.all, Expense.all, Expiration.all, Trade.all].flatten
    @transactions.sort_by!(&:date).reverse!
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:csv)
  end
end
