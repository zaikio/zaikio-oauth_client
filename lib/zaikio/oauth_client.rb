require "oauth2"

require "zaikio/oauth_client/engine"
require "zaikio/oauth_client/configuration"
require "zaikio/oauth_client/authenticatable"

module Zaikio
  module OAuthClient
    class << self
      attr_reader :client_name

      def configure
        @configuration ||= Configuration.new
        yield(configuration)
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def for(client_name = nil)
        client_config_for(client_name).oauth_client
      end

      def oauth_scheme
        @oauth_scheme ||= :request_body
      end

      def with_oauth_scheme(scheme = :request_body)
        @oauth_scheme = scheme
        yield
      ensure
        @oauth_scheme = :request_body
      end

      def with_client(client_name)
        original_client_name = @client_name || nil
        @client_name = client_name
        yield
      ensure
        @client_name = original_client_name
      end

      def with_auth(options_or_access_token, &block)
        access_token = if options_or_access_token.is_a?(Zaikio::AccessToken)
                         options_or_access_token
                       else
                         get_access_token(**options_or_access_token)
                       end

        return unless block_given?

        if configuration.around_auth_block
          configuration.around_auth_block.call(access_token, block)
        else
          yield(access_token)
        end
      end

      def get_access_token(client_name: nil, bearer_type: "Person", bearer_id: nil, scopes: nil) # rubocop:disable Metrics/MethodLength
        client_name ||= self.client_name
        client_config = client_config_for(client_name)
        scopes ||= client_config.default_scopes_for(bearer_type)

        access_token = Zaikio::AccessToken.where(audience: client_config.client_name)
                                          .usable(
                                            bearer_type: bearer_type,
                                            bearer_id: bearer_id,
                                            requested_scopes: scopes
                                          )
                                          .first

        if access_token.blank?
          access_token = Zaikio::AccessToken.build_from_access_token(
            client_config.token_by_client_credentials(
              bearer_type: bearer_type,
              bearer_id: bearer_id,
              scopes: scopes
            ),
            requested_scopes: scopes
          )
          access_token.save!
        elsif access_token&.expired?
          access_token = access_token.refresh!
        end

        access_token
      end

      def get_plain_scopes(scopes)
        regex = /^((Org|Per)\.)?(.*)$/
        scopes.map do |scope|
          (regex.match(scope) || [])[3]
        end.compact
      end

      private

      def client_config_for(client_name = nil)
        raise StandardError.new, "Zaikio::OAuthClient was not configured" unless configuration

        configuration.find!(client_name || configuration.all_client_names.first)
      end
    end
  end
end
