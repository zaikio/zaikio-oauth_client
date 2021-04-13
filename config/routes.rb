Zaikio::OAuthClient::Engine.routes.draw do
  config = Zaikio::OAuthClient.configuration

  scope path: "(/:client_name)" do
    # People
    get "/sessions/new",     action: :new,     controller: config.sessions_controller_name, as: :new_session
    get "/sessions/approve", action: :approve, controller: config.sessions_controller_name, as: :approve_session
    delete "/session",       action: :destroy, controller: config.sessions_controller_name, as: :session

    # Organizations
    get "/connections/new",     action: :new,     controller: config.connections_controller_name, as: :new_connection
    get "/connections/approve", action: :approve, controller: config.connections_controller_name, as: :approve_connection

    # Subscriptions
    get "/subscriptions/new", action: :new, controller: config.subscriptions_controller_name, as: :new_subscription
  end
end
