class UserController < ApplicationController
  before_action :authenticate_user!

  def summary
    year = params[:year]
    @user_summary = YearUserSummaryPresenter.new(year, current_user)
  end
end
