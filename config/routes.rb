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

  resource :production_checklist, only: [:show]
  resources :registrations, only: %i[new]

  resources :ingredients, except: [:show]
  resources :vendors, except: [:show] do
    get :pricing, on: :member
    get :buy_orders, on: :member
    get :print_pricing, on: :collection
    patch :update_pricing, on: :member
    patch :update_buy_orders, on: :member
  end

  resources :recipes, except: [:show] do
    get "created_at", on: :collection
    get "updated_at", on: :collection
    get "papertrail", on: :member
  end

  resources :products do
    get "created_at", on: :collection
    get "updated_at", on: :collection
    get "weekly_daily_report", on: :collection
    get "print_weekly_daily_report", on: :collection
    get "products_per_client_per_week", on: :collection
    get "print_products_per_client_per_week", on: :collection
    get "pricing_report", on: :collection
    get "orders", on: :member
    get "papertrail", on: :member
    get "costing", on: :member
  end

  resources :buy_orders, only: %i[create update index]

  resource :costing, only: %i[create update show update], controller: "costing" do
    get "buying_orders", on: :collection
  end

  resources :routes, except: [:show]

  get "year-total", to: "clients#print_year_total"

  resources :clients do
    get "weekly_daily_report", on: :collection
    get "total_report", on: :collection
    get "print_total_report", on: :collection
    get "print_weekly_daily_report", on: :collection
    get "print_vip_list", on: :collection
    get "print_client_list", on: :collection
    get "set_yearly_clients", on: :collection
    get "yearly_total", on: :collection
  end

  resources :orders, except: [:show] do
    get "created_at", on: :collection
    get "updated_at", on: :collection
    get "papertrail", on: :member
    get "copy", on: :member
    get "print", on: :member
    get :future_invoices, on: :member
    put :add_invoices, on: :member
    get "grocery_list", on: :collection
    get "print_grocery_list", on: :collection
  end

  resources :users, except: [:show] do
    get "myaccount", on: :collection, as: "my"
  end

  resources :reports, only: [:index] do
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
    get "product_invoiced_for_year", on: :collection
    get "detailed_invoice_report", on: :collection
    get "print_detailed_invoice_report", on: :collection
    get "total_sales_report", on: :collection
    get "print_total_sales_report", on: :collection
  end

  resources :bakeries, except: [:show] do
    get "mybakery", on: :collection, as: "my"
  end

  resources :daily_totals, only: [:index] do
    get "print", on: :member
  end

  resources :delivery_lists, only: [:index] do
    get "print", on: :member
    get "print_sorted", on: :member
  end

  resources :packing_slips, only: [:index] do
    get "print", on: :collection
    get "print_list", on: :collection
    get "print_sorted_list", on: :collection
  end

  resources :public_client_users, only: [:index, :new, :create]

  get "print-recipes", to: "production_runs#print_recipes"

  resources :batch_recipes, only: [:index] do
    get "print", on: :collection
    get "export_csv", on: :collection
  end

  resources :production_runs, only: %i[index edit update] do
    get "print", on: :member
    get "print_projection", on: :collection
    get "test_projection", on: :collection
    get "print_test_projection", on: :collection
    get "weekly_daily_production_report", on: :collection
    get "print_weekly_daily_production_report", on: :collection
    get "date_span_production_report", on: :collection
    get "print_date_span_production_report", on: :collection
    put "reset", on: :member
    put "add", on: :member

    resources :run_items
  end

  namespace :api do
    resources :file_exports, only: [:show]
    namespace "v1" do
      resource :account, only: [:show, :update]
      resource :orders, only: [:show, :update]
    end
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
