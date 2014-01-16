FengbNvst::Application.routes.draw do
  resources :investments do
    get 'prices', on: :member
  end

  devise_for :users

  devise_for :admin
  namespace :admin do
    resources :year_summaries
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
