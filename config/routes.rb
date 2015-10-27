Rails.application.routes.draw do

  root to: 'pages#welcome'

#  resources :galleries
  resources :cameras, only: [:index]
  resources :photos, only: [:new, :create]

  get "/login" => "pages#login", as: :login

  get "/welcome" => "pages#welcome", as: :welcome

  get "/faq" => "pages#faq", as: :faq

  get '/users/:user_id/maps/:maps_id/photos/new_multiple', to: 'photos#new_multiple', as: :new_user_map_photo_multiple
 
  #resources :galleries, only: [:index,:show]

  get "/gallery" => "galleries#index", as: :gallery
  get "/gallery/:id" => "galleries#show", as: :gallery_map

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

# Route for Map Rotation

  get 'users/:user_id/maps/rotateccw/:id' => 'maps#rotateCCW', as: :rotateCCW
  get 'users/:user_id/maps/rotatecw/:id' =>  'maps#rotateCW',  as: :rotateCW

#  resources :photos
  resources :maps
 
end
