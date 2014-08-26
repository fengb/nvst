class UserController < ApplicationController
  before_action :authenticate_user!

  def summary
    @user_summaries = YearUserSummaryPresenter.for_user(current_user)
  end
end
