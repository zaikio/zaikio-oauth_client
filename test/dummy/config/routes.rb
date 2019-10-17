Rails.application.routes.draw do
  root to: 'welcomes#index'

  get :login,  to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  mount Zaiku::Engine => "/zaiku"
end
