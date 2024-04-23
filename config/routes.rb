Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/', to: 'home#index'

  resources :merchants, only: [:show, :create] do
    resources :dashboard, only: [:index]
    resources :items, only: [:index, :show, :edit, :update, :new, :create]
    resources :invoices, only: [:index, :show]
    resources :coupons, only: [:index, :show, :new, :create, :update]
  end

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, only: [:index, :show, :edit, :update, :new, :create]
    resources :invoices, only: [:index, :show, :update]
  end

  resources :invoice_items, only: [:update]
end
