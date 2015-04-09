Rails.application.routes.draw do
  devise_for :users
  root 'landing_pages#index'
  get :dashboard, to: 'dashboard#index'

  resources :ingredients, except: [:show]
  resources :recipes, except: [:show]
  resources :products, except: [:show]
  resources :routes, except: [:show]
  resources :clients
  resources :orders, except: [:show]
  resources :users, except: [:show]

  resources :shipments, except: [:show] do
    get 'invoice', on: :member
    get 'packing_slip', on: :member
    get 'invoices', on: :collection
  end

  resources :bakeries, except: [:show] do
    get 'mybakery', on: :collection, as: 'my'
  end

  resources :daily_totals, only: [:index] do
    get 'print', on: :member
  end

  resources :delivery_lists, only: [:index] do
    get 'print', on: :member
  end

  resources :print_recipes, only: [:index]

  resources :production_runs do
    resources :run_items
  end
end
