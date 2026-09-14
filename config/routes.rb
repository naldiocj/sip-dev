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

  # Devise scope for root
  devise_scope :account do
    root to: "sessions#new"
  end

  # Admin namespace
  namespace :admin do
    # Dashboard
    get "dashboard", to: "dashboard#index", as: :dashboard
    
    # Processes
    resources :processes, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        patch :distribute
      end
    end
    
    # Diligences
    resources :diligences, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Documents
    resources :documents, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Mandates
    resources :mandates, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Users
    resources :users, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        post :activate
        post :deactivate
      end
    end
    
    # Organizations
    resources :organizations, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Profiles
    resources :profiles, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Capabilities
    resources :capabilities, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Audit
    get "audit", to: "audit#index", as: :audit
    
    # Evidences
    resources :evidences, only: [:index, :show]
  end
end
