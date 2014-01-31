class Admin::TaxDocsController < Admin::BaseController
  before_action :year_check, except: [:index]

  def index
    # FIXME
    @years = [2013]
  end

  def show
    redirect_to action: :index, anchor: "y#{year}"
  end

  def form_1065
    @form_1065 = TaxDocs::Form1065Presenter.new(year)
  end

  def schedule_d
    @schedule_d = TaxDocs::ScheduleDPresenter.new(year)
  end

  def schedule_k
    @schedule_k = TaxDocs::ScheduleKPresenter.new(year)
  end

  private
  def year_check
    if year.blank?
      return redirect_to '/admin'
    end
  end

  def year
    params[:id]
  end
end
