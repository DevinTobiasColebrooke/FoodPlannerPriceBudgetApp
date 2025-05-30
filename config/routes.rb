Rails.application.routes.draw do
  # Authentication routes
  resource :session
  resources :passwords, param: :token

  # Root route
  root "onboarding/welcome#show"

  # Onboarding routes
  namespace :onboarding do
    resource :welcome, only: [:show]
    resource :disclosure, only: [:show, :update]
    resource :profile_info, only: [:new, :create]
    resource :goal, only: [:new, :create]
    resource :people, only: [:new, :create]
    resource :allergy, only: [:new, :create]
    resource :equipment, only: [:new, :create]
    resource :time_prep, only: [:new, :create]
    resource :shopping, only: [:new, :create]
    resource :avatar, only: [:new, :create]
    resource :finalize, only: [:create]
  end

  # Legal documents
  resources :legal_documents, only: [:show]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
