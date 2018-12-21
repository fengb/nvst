class Admin::PortfolioController < Admin::BaseController
  around_action :skip_bullet, only: :update

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
    transactionable = RailsUtil.all(:models).select { |m| m.respond_to?(:as_transactions) }
    @transactions = transactionable
                      .flat_map(&:as_transactions)
                      .sort_by!(&:date)
                      .reverse!
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:csv)
  end
end
