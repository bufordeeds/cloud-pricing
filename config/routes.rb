Rails.application.routes.draw do
  root "instances#index"

  resources :instances, only: [ :index, :show ]
  resources :llm_models, only: [ :index, :show ]
  get "compare", to: "compare#show"
  get "charts", to: "charts#index"
  get "about", to: "pages#about"

  # API key request flow
  resources :api_key_requests, only: [ :new, :create ], path: "api-access" do
    collection do
      get :thanks
    end
  end

  # Admin panel
  namespace :admin do
    resources :api_keys, only: [ :index ] do
      member do
        post :approve
        post :deny
        post :revoke
      end
    end
  end

  # JSON API
  namespace :api do
    namespace :v1 do
      resources :instances, only: [ :index, :show ]
      resources :llm_models, only: [ :index, :show ]
      resources :providers, only: [ :index ]
      resources :llm_providers, only: [ :index ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
