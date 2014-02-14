class Admin::UserSummariesController < Admin::BaseController
  def index
    # FIXME: get active years
    @years = [2013]
    @users = User.all
  end

  def show
    year = params[:year]
    user = User.find(params[:user_id])
    @user_summary = YearUserSummaryPresenter.new(year, user)
  end
end
