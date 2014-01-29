Nvst::Application.routes.draw do
  root to: 'portfolio#index'

  resource :portfolio, controller: :portfolio do
    member do
      get 'benchmark'
      get 'principal'
    end
  end

  resources :investments do
    member do
      get 'prices'
    end
  end

  devise_for :users

  devise_for :admin
  namespace :admin do
    resources :year_summaries do
      member do
        get 'form_1065'
        get 'schedule_d'
        get 'schedule_k'
      end
    end
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
