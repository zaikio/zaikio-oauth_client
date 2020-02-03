Rails.application.routes.draw do
  # Concerns
  concern :autocompleteable do
    get 'autocomplete', on: :collection
  end

  root to: 'welcomes#index'
  resource :current_person, only: [:show], controller: 'current_person'
  
  get "/:scope(/:page)" => "pages#show"

  mount Zaikio::Engine => "/zaikio"
end
