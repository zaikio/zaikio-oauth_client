Rails.application.routes.draw do
  # Concerns
  concern :autocompleteable do
    get 'autocomplete', on: :collection
  end
  
  root to: 'welcomes#index'

  resources :elements, concerns: :autocompleteable

  mount Zaikio::Engine => "/zaikio"
end
