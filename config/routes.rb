Rails.application.routes.draw do
  # Devise authentication routes
  devise_for :accounts,
    path: "auth",
    controllers: {
      sessions: "sessions",
      registrations: "registrations",
      passwords: "passwords",
      confirmations: "confirmations"
    }

  # Authentication routes with friendly aliases
  get "auth/login" => "sessions#new", as: :auth_login
  get "auth/logout" => "sessions#destroy", as: :auth_logout
  post "auth/logout" => "sessions#destroy"
  delete "auth/logout" => "sessions#destroy"
  get "auth/sign_up" => "registrations#new", as: :auth_sign_up
  get "auth/password/new" => "passwords#new", as: :auth_password_new
  get "auth/password/edit" => "passwords#edit", as: :auth_password_edit
  post "auth/password" => "passwords#update", as: :auth_password
  patch "auth/password" => "passwords#update"
  put "auth/password" => "passwords#update"
  get "auth/confirmation/new" => "confirmations#new", as: :auth_confirmation_new
  post "auth/confirmation" => "confirmations#create", as: :auth_confirmation
  put "auth/confirmation" => "confirmations#update"

  # Root → login page
  root "sessions#new"

  # Admin namespace
  namespace :admin do
    # Dashboard
    get "dashboard", to: "dashboard#index", as: :dashboard

    # Processes
    resources :processes, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
      member do
        patch :distribute
      end
    end

    # Diligences
    resources :diligences, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # Documents
    resources :documents, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # Mandates
    resources :mandates, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # Users
    resources :users, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
      member do
        post :activate
        post :deactivate
      end
    end

    # Organizations
    resources :organizations, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # Profiles
    resources :profiles, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # Capabilities
    resources :capabilities, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # Audit
    get "audit", to: "audit#index", as: :audit

    # Evidences
    resources :evidences, only: [ :index, :show ]
  end
end
