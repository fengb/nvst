class Admin::TaxDocsController < Admin::BaseController
  before_action :set_year_summary, except: [:index]

  def index
    @years = [2013]
  end

  def show
    redirect_to action: :index, anchor: "y#{year}"
  end

  def schedule_k
    @schedule_k = TaxDocs::ScheduleKPresenter.new(year)
  end

  private
  def set_year_summary
    if year.blank?
      return redirect_to '/admin'
    end
    @year_summary = TaxDocs::YearSummaryPresenter.new(year)
  end

  def year
    params[:id]
  end
end
