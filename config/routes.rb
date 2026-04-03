Rails.application.routes.draw do
  root "instances#index"

  resources :instances, only: [ :index, :show ]
  resources :llm_models, only: [ :index, :show ]
  get "compare", to: "compare#show"
  get "charts", to: "charts#index"
  get "about", to: "pages#about"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
