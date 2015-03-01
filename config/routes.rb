Rails.application.routes.draw do
  devise_for :users
  root 'static_pages#index'
  resources :ingredients
  resources :recipes
  resources :products
  resources :routes
  resources :clients
  resources :orders
  resources :users

  resources :shipments do
    get 'invoices', on: :collection
  end

  resources :bakeries do
    get 'mybakery', on: :collection, as: 'my'
  end

  resources :daily_totals, only: [:index] do
    get 'print', on: :member
  end
end
