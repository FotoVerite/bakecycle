Rails.application.routes.draw do
  root 'landing_pages#index'
  devise_for :users, skip: [:invitations]
  devise_scope :user do
    post '/users/invitations/send_email', to: 'users/invitations#send_email', as: 'send_user_invitation'
    get '/users/invitations/accept', to: 'users/invitations#edit', as: 'accept_user_invitation'
    put '/users/invitations/', to: 'users/invitations#update', as: 'user_invitation'
    post '/users/invitations/', to: 'users/invitations#create'
  end
  get :sign_in, to: 'landing_pages#sign_in'
  get 'privacy_policy', to: 'landing_pages#privacy_policy'
  get 'terms_of_service', to: 'landing_pages#terms_of_service'
  get 'plans', to: 'landing_pages#plans'
  get :dashboard, to: 'dashboard#index'

  resources :registrations, only: [:new, :create]

  resources :ingredients, except: [:show]
  resources :recipes, except: [:show]
  resources :products, except: [:show]
  resources :routes, except: [:show]
  resources :clients
  resources :orders, except: [:show] do
    get 'copy', on: :member
  end
  resources :users, except: [:show] do
    get 'myaccount', on: :collection, as: 'my'
  end

  resources :file_exports, only: [:show]

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

  resources :packing_slips, only: [:index] do
    get 'print', on: :collection
  end

  get 'active-orders', to: 'orders#active_orders'
  get 'print-recipes', to: 'production_runs#print_recipes'

  resources :batch_recipes, only: [:index] do
    get 'print', on: :collection
    get 'export_csv', on: :collection
  end

  resources :production_runs, only: [:index, :edit, :update] do
    get 'print', on: :member
    get 'print_projection', on: :collection
    put 'reset', on: :member

    resources :run_items
  end

  namespace :api do
    resources :file_exports, only: [:show]
  end

  # If user is not an admin it 404s the resque request
  resque_web_constraint = lambda do |request|
    current_user = request.env['warden'].user
    current_user && Ability.new(current_user).can?(:manage, :resque)
  end
  constraints resque_web_constraint do
    mount Resque::Server, at: '/resque'
  end
end
