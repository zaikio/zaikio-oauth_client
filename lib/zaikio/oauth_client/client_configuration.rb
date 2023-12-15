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
          connection_opts: { headers: { Accept: "application/json" } },
          site: Zaikio::OAuthClient.configuration.host
        )

        @oauth_client.options[:auth_scheme] = Zaikio::OAuthClient.oauth_scheme

        @oauth_client
      end

      def scopes_for_auth(_id = nil)
        default_scopes
      end

      def default_scopes_for(type = "Person")
        type == "Organization" ? org_config.default_scopes : default_scopes
      end

      def token_by_client_credentials(bearer_id: nil, bearer_type: "Person", scopes: [])
        plain_scopes = Zaikio::OAuthClient.get_plain_scopes(scopes)
        scopes_with_prefix = plain_scopes.map do |scope|
          "#{bearer_type[0..2]}/#{bearer_id}.#{scope}"
        end

        Zaikio::OAuthClient.with_oauth_scheme(:basic_auth) do
          oauth_client.client_credentials.get_token(scope: scopes_with_prefix.join(","))
        end
      rescue OAuth2::Error => e
        if e.response.body.include?("bearer_does_not_exist")
          Rails.logger.error "#{bearer_type[0..2]}/#{bearer_id} does not exist"
          return
        end

        raise e
      end

      class OrganizationConnection
        attr_accessor :default_scopes

        def initialize
          @default_scopes = []
        end

        def scopes_for_auth(id = nil)
          plain_scopes = Zaikio::OAuthClient.get_plain_scopes(default_scopes)

          plain_scopes.map do |scope|
            id ? "Org/#{id}.#{scope}" : "Org.#{scope}"
          end
        end
      end
    end
  end
end
