Nvst::Application.routes.draw do
  root 'portfolio#index'

  resource :portfolio, controller: :portfolio

  controller :user do
    get 'summary', action: :summary
  end

  devise_for :users

  devise_for :admin
  namespace :admin do
    resource :portfolio, controller: :portfolio

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

    resources :user_summaries
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
