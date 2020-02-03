Zaikio::Engine.routes.draw do
  resources :sessions, only: [:new] do
    get :approve, on: :collection
  end
  resource :session, only: [:destroy]
end
