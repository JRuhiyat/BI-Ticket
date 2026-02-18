Rails.application.routes.draw do
  root "sessions#new"
  
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  get "dashboard", to: "dashboard#index"
  
  resources :tickets, only: [:index, :show]
  
  resources :uploads, only: [:new, :create]
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
