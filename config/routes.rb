Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Root → login page (devise_scope so warden knows the mapping)
  devise_scope :account do
    root to: "sessions#new"
    get "/auth/login"    => "sessions#new",  as: :auth_login
    post "/auth/login"   => "sessions#create"
    delete "/auth/logout" => "sessions#destroy", as: :auth_logout
  end

  devise_for :accounts, controllers: {
    sessions: "sessions",
    registrations: "registrations",
    passwords: "passwords",
    confirmations: "confirmations"
  }, path: "auth"

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :organizations
    resources :users do
      member do
        post "activate"
        post "deactivate"
      end
    end
    resources :profiles
    resources :capabilities
    resources :processes, controller: "sip_processes" do
      member do
        post "distribute"
      end
    end
    resources :diligences
    resources :documents do
      member do
        get "download"
      end
    end
    resources :mandates do
      member do
        post "execute"
        post "cancel"
      end
    end
    resources :evidences do
      member do
        get "download"
      end
    end
    end
end
