class Admin::TaxDocsController < Admin::BaseController
  before_action :set_year_summary, except: [:index]

  def index
    @years = [2013]
  end

  private
  def set_year_summary
    if params[:id].blank?
      return redirect_to '/admin'
    end
    @year_summary = YearSummaryPresenter.new(params[:id])
  end
end
