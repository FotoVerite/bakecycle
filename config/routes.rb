Rails.application.routes.draw do
  root "landing_pages#index"
  devise_for :users, skip: [:invitations]
  devise_scope :user do
    post "/users/invitations/send_email", to: "users/invitations#send_email", as: "send_user_invitation"
    get "/users/invitations/accept", to: "users/invitations#edit", as: "accept_user_invitation"
    put "/users/invitations/", to: "users/invitations#update", as: "user_invitation"
    post "/users/invitations/", to: "users/invitations#create"
  end
  get :sign_in, to: "landing_pages#sign_in"
  get "privacy-policy", to: "landing_pages#privacy_policy"
  get "terms-of-service", to: "landing_pages#terms_of_service"
  get "plans", to: "landing_pages#plans"
  get :dashboard, to: "dashboard#index"

  resources :registrations, only: %i(new create)

  resources :ingredients, except: [:show]
  resources :recipes, except: [:show] do
    get "created_at", on: :collection
    get "updated_at", on: :collection
    get "papertrail", on: :member
  end

  resources :products, except: [:show] do
    get "created_at", on: :collection
    get "updated_at", on: :collection
    get "papertrail", on: :member
  end
  resources :routes, except: [:show]
  resources :clients
  resources :orders, except: [:show] do
    get "created_at", on: :collection
    get "updated_at", on: :collection
    get "papertrail", on: :member
    get "copy", on: :member
    get "print", on: :member
    get :future_invoices, on: :member
    put :add_invoices, on: :member
  end
  resources :users, except: [:show] do
    get "myaccount", on: :collection, as: "my"
  end

  resources :file_actions, only: [:index]

  resources :file_exports, only: [:show]

  resources :shipments, path: "invoices", except: [:show] do
    get "invoice", on: :member
    get "invoice_iif", on: :member
    get "invoice_csv", on: :member
    get "packing_slip", on: :member
    get "export_pdf", on: :collection
    get "export_csv", on: :collection
    get "export_iif", on: :collection
  end

  resources :bakeries, except: [:show] do
    get "mybakery", on: :collection, as: "my"
  end

  resources :daily_totals, only: [:index] do
    get "print", on: :member
  end

  resources :delivery_lists, only: [:index] do
    get "print", on: :member
  end

  resources :packing_slips, only: [:index] do
    get "print", on: :collection
    get "print_list", on: :collection
  end

  get "print-recipes", to: "production_runs#print_recipes"

  resources :batch_recipes, only: [:index] do
    get "print", on: :collection
    get "export_csv", on: :collection
  end

  resources :production_runs, only: %i(index edit update) do
    get "print", on: :member
    get "print_projection", on: :collection
    get "test_projection", on: :collection
    get "print_test_projection", on: :collection
    get "weekly_daily_production_report", on: :collection
    get "print_weekly_daily_production_report", on: :collection
    put "reset", on: :member
    put "add", on: :member

    resources :run_items
  end

  namespace :api do
    resources :file_exports, only: [:show]
  end

  # If user is not an admin it 404s the resque request
  resque_web_constraint = lambda do |request|
    current_user = request.env["warden"].user
    current_user && JobPolicy.new(current_user, User).dashboard?
  end
  constraints resque_web_constraint do
    mount Resque::Server, at: "/resque"
  end

  get "robots.txt", to: "robots#robots"
end
