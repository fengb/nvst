class RailsAdminController < ApplicationController
  around_action :skip_bullet if defined?(Bullet)

  def skip_bullet
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = true
  end
end
