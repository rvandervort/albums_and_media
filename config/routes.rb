Rails.application.routes.draw do

  post "/albums/:album_id/:media_type/:media_type_id",  to: "content_lists#create"
  delete "/albums/:album_id/:media_type/:media_type_id",  to: "content_lists#destroy"

  resources :albums do
    resources :photos, only: [:index, :create]
    resources :videos, only: [:index, :create]
  end

  resources :photos, only: [:index, :destroy, :show, :update]
  resources :videos, only: [:index, :destroy, :show, :update]
end
