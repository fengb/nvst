class Admin::UserSummariesController < Admin::BaseController
  def index
    @users = User.all
  end

  def show
    user = User.find(params[:id])
    @user_growths = UserYearGrowthPresenter.for_user(user)
    render 'user/summary'
  end
end
