Rails.application.routes.draw do
  resources :cameras
  resources :photos, only: [:new, :create]
#  get '/photos/new_multiple', to: 'photos#new_multiple', as: :new_photo_multiple
  get '/users/:user_id/maps/:maps_id/photos/new_multiple', to: 'photos#new_multiple', as: :new_user_map_photo_multiple

  root to: 'pages#login'
 
  get "/login" => "pages#login", as: :login

  resources :users do
    resources :maps do
      resources :photos 
    end
  end

#custom routes to fix this nested ish?
 
#  get 'user/:user_id/maps', to: 'maps#index', as: :maps
#  get 'user/:user_id/maps/:id', to: 'maps#show', as: :map

#  get 'user/:user_id/maps/:maps_id/photos', to: 'photos#index', as: :photos
#  get 'user/:user_id/maps/:maps_id/photos/:id', to: 'photos#show', as: :show_photo

# Omniauth
  delete '/logout', to: 'sessions#destroy'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#auth_failure'

# Route for generating mosaic

  get 'users/:user_id/maps/generate/:id' => 'maps#generate', as: :generate
#  get 'maps/generate/:id' => 'maps#generate', as: :generate

# General Login
#  root to: 'pages#index'

#  resources :maps, :only => [:index, :show]

#  resources :photos
  resources :maps
 
end
