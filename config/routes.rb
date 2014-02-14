Nvst::Application.routes.draw do
  root to: 'portfolio#show'

  resource :portfolio, controller: :portfolio

  resources :investments do
    member do
      get 'prices'
    end
  end

  devise_for :users

  devise_for :admin
  namespace :admin do
    resource :portfolio, controller: :portfolio

    resources :tax_docs do
      member do
        get 'form_1065'
        get 'schedule_d'
        get 'schedule_k'
      end
    end

    resources :user_summaries
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
