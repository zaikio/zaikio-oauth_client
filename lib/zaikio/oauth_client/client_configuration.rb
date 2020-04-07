module Zaikio
  module OAuthClient
    class ClientConfiguration
      attr_reader :org_config, :client_name
      attr_accessor :client_id, :client_secret, :default_scopes

      def initialize(client_name)
        @default_scopes = []
        @client_name = client_name
      end

      def register_organization_connection
        @org_config ||= OrganizationConnection.new
        yield(@org_config)
      end

      def oauth_client
        @oauth_client ||= OAuth2::Client.new(
          client_id,
          client_secret,
          authorize_url: "oauth/authorize",
          token_url: "oauth/access_token",
          connection_opts: { headers: { "Accept": "application/json" } },
          site: Zaikio::OAuthClient.configuration.host
        )

        @oauth_client.options[:auth_scheme] = Zaikio::OAuthClient.oauth_scheme

        @oauth_client
      end

      def scopes_for_auth
        default_scopes
      end

      def default_scopes_for(type = "Person")
        type == "Organization" ? org_config.default_scopes : default_scopes
      end

      def token_by_client_credentials(bearer_id: nil, bearer_type: "Person", scopes: [])
        regex = /^((Org|Per)\.)?(.*)$/
        scopes_with_prefix = scopes.map do |scope|
          plain_scope = (regex.match(scope) || [])[3]
          "#{bearer_type[0..2]}/#{bearer_id}.#{plain_scope}"
        end

        Zaikio::OAuthClient.with_oauth_scheme(:basic_auth) do
          oauth_client.client_credentials.get_token(scope: scopes_with_prefix.join(","))
        end
      end

      class OrganizationConnection
        attr_accessor :default_scopes

        def initialize
          @default_scopes = []
        end

        def scopes_for_auth
          default_scopes.map do |scope|
            scope.start_with?("Org") ? scope : "Org.#{scope}"
          end
        end
      end
    end
  end
end
