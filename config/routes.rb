Rails.application.routes.draw do
  resources :albums do
    resources :photos, only: [:index, :create]
    resources :videos, only: [:index, :create]
  end

  resources :photos, only: [:index, :destroy, :show, :update]
  resources :videos, only: [:index, :destroy, :show, :update]
end
