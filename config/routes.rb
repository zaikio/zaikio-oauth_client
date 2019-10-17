Zaiku::Engine.routes.draw do
  resources :sessions, only: %w( new destroy ) do
    get :approve, on: :collection
  end
end
