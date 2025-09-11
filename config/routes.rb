Rails.application.routes.draw do
  resources :posts
  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :users

resources :books do
  resources :chapters do
    resources :pages do
      member do
        post :generate_image
      end
    end
  end
  member do
    get :public, to: 'books#public_show'
    post :save,   to: 'saved_books#create'
    delete :unsave, to: 'saved_books#destroy'
    post :generate_audio, to: 'books#generate_audio'
    patch :publish, to: 'books#publish'
    patch :archive, to: 'books#archive'
    patch :unarchive, to: 'books#unarchive'
  end
  collection do
    get :library, to: 'books#library'
    get ':id/read', to: 'books#reader', as: :read
  end
end

  mount LlamaBotRails::Engine => "/llama_bot"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "public#home"
  get "home" => "public#home"

  # Defines the root path route ("/")
  # root "posts#index"
end
