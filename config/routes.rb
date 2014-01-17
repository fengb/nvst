FengbNvst::Application.routes.draw do
  resources :investments do
    member do
      get 'prices'
      get 'benchmark'
    end
  end

  devise_for :users

  devise_for :admin
  namespace :admin do
    resources :year_summaries
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
