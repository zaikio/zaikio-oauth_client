Zaikio::OAuthClient::Engine.routes.draw do
  # People
  get "(/:client_name)/sessions/new", to: "sessions#new", as: :new_session
  get "(/:client_name)/sessions/approve", to: "sessions#approve", as: :approve_session
  delete "(/:client_name)/session", to: "sessions#destroy", as: :session

  # Organizations
  get "(/:client_name)/connections/new", to: "connections#new", as: :new_connection
  get "(/:client_name)/connections/approve", to: "connections#approve", as: :approve_connection
end
