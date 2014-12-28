Nvst::Application.routes.draw do
  root 'portfolio#index'

  resource :portfolio, controller: :portfolio

  controller :user do
    get 'summary'
  end

  devise_for :users

  devise_for :admin
  namespace :admin do
    resource :portfolio, controller: :portfolio do
      member do
        get 'growth'
        get 'transactions'
      end
    end

    resource :summaries do
      member do
        get 'user/:user_id', action: 'user', as: 'user'
        get 'year/:year',    action: 'year', as: 'year'
      end
    end

    resources :investments do
      member do
        get 'prices'
      end
    end

    resources :tax_docs do
      member do
        get 'form_1065'
        get 'schedule_d'
        get 'schedule_k'
      end
    end
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
