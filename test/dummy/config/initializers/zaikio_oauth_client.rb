Zaikio::OAuthClient.configure do |config|
  config.environment = :test
  config.sessions_controller_name = "sessions"
  config.register_client :warehouse do |warehouse|
    warehouse.client_id = "da6333fc-19ab-51d7-8295-4904358c5ecb"
    warehouse.client_secret = "e415a98b72f0b48f554de75756f31780"
    warehouse.default_scopes = %w[directory.person.r]

    warehouse.register_organization_connection do |org|
      org.default_scopes = %w[directory.organization.r]
    end
  end
end
