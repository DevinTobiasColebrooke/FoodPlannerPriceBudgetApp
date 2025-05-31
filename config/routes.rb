Rails.application.routes.draw do
  get "settings/show"
  get "settings/edit"
  get "settings/update"
  get "shopping_list_items/create"
  get "shopping_list_items/update"
  get "shopping_list_items/destroy"
  get "shopping_lists/index"
  get "shopping_lists/show"
  get "shopping_lists/new"
  get "shopping_lists/create"
  get "shopping_lists/edit"
  get "shopping_lists/update"
  get "shopping_lists/destroy"
  get "meal_plans/index"
  get "recipes/show"
  get "dashboard/show"
  # Authentication routes
  resource :session
  resources :passwords, param: :token

  # Root route
  authenticated :user do
    root 'dashboard#show', as: :authenticated_root
  end
  root "sessions#new" # if not authenticated

  # Onboarding routes
  namespace :onboarding do
    resource :welcome, only: [:show], controller: 'welcome' do
      member do
        post :start
      end
    end
    resource :disclosure, only: [:show, :update], controller: 'disclosures' do
      member do
        get :back
      end
    end
    resource :profile_info, only: [:show, :update], controller: 'profile_info' do
      member do
        get :back
      end
    end
    resource :goal, only: [:new, :create], controller: 'goals' do
      member do
        get :back
      end
    end
    resource :people, only: [:new, :create], controller: 'people' do
      member do
        get :back
      end
    end
    resource :allergy, only: [:new, :create], controller: 'allergies' do
      member do
        get :back
      end
    end
    resource :equipment, only: [:new, :create], controller: 'equipment' do
      member do
        get :back
      end
    end
    resource :time_prep, only: [:new, :create], controller: 'time_prep' do
      member do
        get :back
      end
    end
    resource :shopping, only: [:new, :create], controller: 'shopping' do
      member do
        get :back
      end
    end
    resource :avatar, only: [:new, :create], controller: 'avatars' do
      member do
        get :back
      end
    end
    resource :finalize, only: [:new, :create], controller: 'finalize'
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
