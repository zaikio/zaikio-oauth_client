Rails.application.routes.draw do
  root to: 'welcomes#index'

  resources :elements

  mount Zaiku::Engine => "/zaiku"
end
