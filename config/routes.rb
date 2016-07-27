Rails.application.routes.draw do
  resources :albums do
    resources :photos, only: [:index, :create]
  end

  resources :photos, only: [:index, :destroy, :show, :update]
end
