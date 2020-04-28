Zaikio::OAuthClient::Engine.routes.draw do
  sessions_controller = Zaikio::OAuthClient.configuration.sessions_controller_name
  connections_controller = Zaikio::OAuthClient.configuration.connections_controller_name

  # People
  get "(/:client_name)/sessions/new", action: :new, controller: sessions_controller, as: :new_session
  get "(/:client_name)/sessions/approve", action: :approve, controller: sessions_controller, as: :approve_session
  delete "(/:client_name)/session", action: :destroy, controller: sessions_controller, as: :session

  # Organizations
  get "(/:client_name)/connections/new", action: :new,
                                         controller: connections_controller, as: :new_connection
  get "(/:client_name)/connections/approve", action: :approve,
                                             controller: connections_controller, as: :approve_connection
end
