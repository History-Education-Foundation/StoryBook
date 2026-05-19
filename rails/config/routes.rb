Rails.application.routes.draw do
  resources :historical_figures
  resources :posts, only: [:index, :show, :new, :create]
  devise_for :users, controllers: { registrations: "users/registrations" }
  resources :users

  resources :books do
    resources :chapters do
      resources :pages do
        member do
          post :generate_image
          post :delete_image
        end
      end
    end
    member do
      get :public, to: "books#public_show"
      get :builder, to: "books#builder"
      post :save,   to: "saved_books#create"
      delete :unsave, to: "saved_books#destroy"
      post :generate_audio, to: "books#generate_audio"
      post :generate_all_pictures, to: "books#generate_all_pictures"
      post :retry_failed_pictures, to: "books#retry_failed_pictures"
      patch :publish, to: "books#publish"
      patch :archive, to: "books#archive"
      patch :unarchive, to: "books#unarchive"
      get :audio_playlist, to: "books#audio_playlist"
    end
    collection do
      get :library, to: "books#library"
      get ":id/read", to: "books#reader", as: :read
    end
  end

  mount LlamaBotRails::Engine => "/llama_bot"

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "public#home"
  get "home" => "public#home"
  get "chat" => "public#chat"
  get "pricing", to: "static_pages#pricing"
  get "about", to: "static_pages#about"
  
  resources :lesson_plans, path: "lesson_plan", only: [:show]
  get "lesson_plans", to: "lesson_plans#index", as: :lesson_plans
  resources :civics, only: [:index, :show]

  get "contact", to: "static_pages#contact"
  
  resources :concepts, only: [:index, :show]
  resources :scholars, only: [:index, :show]
  resources :controversies, only: [:index, :show]

  namespace :admin do
    root to: "dashboard#index"
    
    resources :users do
      member do
        post :impersonate
      end
    end

    resources :posts
    resources :categories
    resources :authors
  end

  post "/stop_impersonating", to: "application#stop_impersonating"

  post "/webhooks/recall", to: "webhooks#recall"

  get "/prototypes/*page", to: "prototypes#show"
end
