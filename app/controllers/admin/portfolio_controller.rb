class Admin::PortfolioController < Admin::BaseController
  def show
    @lot_summaries = LotSummaryPresenter.all
  end
end
