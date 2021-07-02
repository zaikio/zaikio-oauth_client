require "oauth2"

require "zaikio/oauth_client/error"
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

        return unless block

        if configuration.around_auth_block
          configuration.around_auth_block.call(access_token, block)
        else
          yield(access_token)
        end
      end

      # Finds the best possible access token, using the DB or an API call
      #   * If the token has expired, it will be refreshed using the refresh_token flow
      #     (if this fails, we fallback to getting a new token using client_credentials)
      #   * If the token does not exist, we'll get a new one using the client_credentials flow
      def get_access_token(bearer_id:, client_name: nil, bearer_type: "Person", scopes: nil)
        client_config = client_config_for(client_name || self.client_name)
        scopes ||= client_config.default_scopes_for(bearer_type)

        token = find_usable_access_token(client_name: client_config.client_name,
                                         bearer_type: bearer_type,
                                         bearer_id: bearer_id,
                                         requested_scopes: scopes)

        token = token.refresh! if token&.expired?

        token ||= fetch_new_token(client_config: client_config,
                                  bearer_type: bearer_type,
                                  bearer_id: bearer_id,
                                  scopes: scopes)
        token
      end

      # Finds the best usable access token. Note that this token may have expired and
      # would require refreshing.
      def find_usable_access_token(client_name:, bearer_type:, bearer_id:, requested_scopes:)  # rubocop:disable Metrics/MethodLength
        configuration.logger.debug "Try to fetch token for client_name: #{client_name}, "\
                                   "bearer #{bearer_type}/#{bearer_id}, requested_scopes: #{requested_scopes}"

        fetch_access_token = lambda {
          Zaikio::AccessToken
            .where(audience: client_name)
            .usable(
              bearer_type: bearer_type,
              bearer_id: bearer_id,
              requested_scopes: requested_scopes
            )
            .first
        }

        if configuration.logger.respond_to?(:silence)
          configuration.logger.silence { fetch_access_token.call }
        else
          fetch_access_token.call
        end
      end

      def fetch_new_token(client_config:, bearer_type:, bearer_id:, scopes:)
        Zaikio::AccessToken.build_from_access_token(
          client_config.token_by_client_credentials(
            bearer_type: bearer_type,
            bearer_id: bearer_id,
            scopes: scopes
          ),
          requested_scopes: scopes
        ).tap(&:save!)
      end

      def get_plain_scopes(scopes)
        regex = /^((Org|Per)\.)?(.*)$/
        scopes.filter_map do |scope|
          (regex.match(scope) || [])[3]
        end
      end

      private

      def client_config_for(client_name = nil)
        raise StandardError.new, "Zaikio::OAuthClient was not configured" unless configuration

        configuration.find!(client_name || configuration.all_client_names.first)
      end
    end
  end
end
