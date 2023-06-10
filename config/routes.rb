Rails.application.routes.draw do
  # main controller
  root "main#home"

  #users controller
  get  '/signup',  to: 'users#new'
  resources :users

  #sessions controller
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  #Auth0
  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'
end
