class RailsAdminController < ApplicationController
  around_action :skip_bullet
end
