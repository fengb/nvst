class Admin::SummariesController < Admin::BaseController
  def show
    @users = User.all
    # FIXME
    @years = [2013, 2014, 2015, 2016]
  end

  def user
    user = User.find(params[:user_id])
    @user_growths = UserYearGrowthPresenter.for_user(user)
    render 'user/summary'
  end

  def year
    year = params[:year].to_i
    @growths = UserYearGrowthPresenter.for_year(year)
  end
end
