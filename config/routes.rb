Rails.application.routes.draw do
  resources :albums do
    resources :photos, only: [:index, :create]
  end

  resources :photos, only: [:destroy, :show, :update]
end
