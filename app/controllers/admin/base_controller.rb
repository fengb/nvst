class Admin::BaseController < ActionController::Base
  layout 'application'

  before_action :authenticate_admin!
end
