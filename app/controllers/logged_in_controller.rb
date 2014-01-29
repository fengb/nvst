class LoggedInController < ApplicationController
  before_action :authenticate_user!, unless: :admin_signed_in?
end
