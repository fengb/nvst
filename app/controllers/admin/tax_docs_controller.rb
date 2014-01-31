class Admin::TaxDocsController < Admin::BaseController
  before_action :set_year_summary, except: [:index]

  def index
    @years = [2013]
  end

  def schedule_k
    @schedule_k = ScheduleKPresenter.new(year)
  end

  private
  def set_year_summary
    if year.blank?
      return redirect_to '/admin'
    end
    @year_summary = YearSummaryPresenter.new(year)
  end

  def year
    params[:id]
  end
end
