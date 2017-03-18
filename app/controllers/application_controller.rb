class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) << :username
  end

  if defined?(Bullet)
    def skip_bullet
      Bullet.enable = false
      yield
    ensure
      Bullet.enable = true
    end
  else
    def skip_bullet
      yield
    end
  end
end
