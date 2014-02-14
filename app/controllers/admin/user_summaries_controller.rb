class Admin::UserSummariesController < Admin::BaseController
  def index
    @users = User.all
    @years = [2013]
  end
end
