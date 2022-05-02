Rails.application.routes.draw do
  resources :recipes
  resources :users
  
  get "/grocery_list", to: "home#get_grocery_list"
  get "/ingredients_list", to: "home#get_ingredients_list"

  get '/signup', to: "users#new"
  post '/signup', to: "users#create"

  get '/login', to: "sessions#new"
  post '/login', to: "sessions#create"
  get '/logout', to: "sessions#destroy"

  root to: "sessions#new"
end