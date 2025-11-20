Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      get 'auth/me', to: 'auth#me'

      # Categories
      resources :categories, only: [:index, :show]

      # Provider Profiles
      resource :provider_profile, only: [:show, :create, :update]

      # Jobs
      resources :jobs, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :assign_provider
        end
      end

      # Bids
      resources :bids, only: [:index, :show, :create, :update, :destroy]

      # Subscriptions
      resources :subscriptions, only: [:index, :show, :create] do
        collection do
          get :current
        end
      end

      # Payments
      resources :payments, only: [:index, :show, :create, :update]

      # Messages
      resources :messages, only: [:index, :create] do
        collection do
          get :conversations
          post :mark_as_read
        end
      end

      # Admin
      get 'admin/dashboard', to: 'admin#dashboard'
      get 'admin/pending_providers', to: 'admin#pending_providers'
      get 'admin/pending_payments', to: 'admin#pending_payments'
      post 'admin/providers/:id/approve', to: 'admin#approve_provider'
      post 'admin/providers/:id/reject', to: 'admin#reject_provider'
      post 'admin/payments/:id/approve', to: 'admin#approve_payment'
      post 'admin/payments/:id/reject', to: 'admin#reject_payment'
    end
  end

  # ActionCable
  mount ActionCable.server => '/cable'
end
