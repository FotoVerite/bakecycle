Rails.application.routes.draw do
  devise_for :users
  root 'static_pages#index'
  resources :ingredients
  resources :recipes
  resources :products
  resources :routes
  resources :clients
  resources :orders
  resources :shipments
end
