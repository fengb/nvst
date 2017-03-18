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
      GenerateActivitiesJob.perform_now
    end

    redirect_to action: 'show'
  end

  def transactions
    @transactions = [
      *Contribution.all.includes(:user),
      *Event.all.includes(:src_investment),
      *Expense.all,
      *Expiration.all.includes(:investment),
      *Trade.all.includes(:investment),
    ]
    @transactions.sort_by!(&:date).reverse!
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:csv)
  end
end
