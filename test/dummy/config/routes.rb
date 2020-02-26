Rails.application.routes.draw do
  root to: 'welcomes#index'
  resource :current_person, only: [:show], controller: 'current_person'

  mount Zaikio::Engine => "/zaikio"
end
