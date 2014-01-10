class Admin::YearSummariesController < Admin::BaseController
  before_action :set_year_summary, except: [:index]

  def index
    @years = [2013]
  end

  def show
    render layout: 'application'
  end

  private
  def set_year_summary
    if params[:id].blank?
      return redirect_to '/admin'
    end
    @year_summary = YearSummaryPresenter.new(params[:id])
  end
end
