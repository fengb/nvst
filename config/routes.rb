FengbNvst::Application.routes.draw do
  devise_for :users

  devise_for :admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
