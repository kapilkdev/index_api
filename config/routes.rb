require 'sidekiq/web'
Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  default_url_options :host => "example.com"
  mount Sidekiq::Web => "/sidekiq"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  post "/users", to: "users#create"
  post "/auth/login", to: "auth#login"
  post 'passwords/forgot', to: 'passwords#forgot'
  post 'passwords/reset', to: 'passwords#reset'
  resources :articles do
    collection do
      get :view_hidden_articles
      get :search_articles
    end
    member do
      put :revert_to
      get :fetch_versions
    end
    resources :comments
  end
  resources :categories,only: [:index]
end
