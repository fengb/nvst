class Admin::PortfolioController < Admin::BaseController
  def show
    @position_summaries = PositionSummaryPresenter.all
  end
end
