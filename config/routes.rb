Zaiku::Engine.routes.draw do
  resources :sessions, only: %w( new ) do
    get approve, on: :collection
  end
end
