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

  resources :shipments, except: [:show] do
    get 'invoice', on: :member
    get 'packing_slip', on: :member
    get 'invoices', on: :collection
  end

  resources :bakeries do
    get 'mybakery', on: :collection, as: 'my'
  end

  resources :daily_totals, only: [:index] do
    get 'print', on: :member
  end

  resources :delivery_lists, only: [:index] do
    get 'print', on: :member
  end
end
