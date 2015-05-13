Rails.application.routes.draw do
  root 'landing_pages#index'
  devise_for :users
  get :sign_in, to: 'landing_pages#sign_in'
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
    get 'invoice_iif', on: :member
    get 'packing_slip', on: :member
    get 'invoices', on: :collection
    get 'invoices_csv', on: :collection
    get 'invoices_iif', on: :collection
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

  get 'active-orders', to: 'orders#active_orders'
  get 'print-recipes', to: 'production_runs#print_recipes'

  resources :production_runs do
    get 'print', on: :member
    resources :run_items
  end
end
