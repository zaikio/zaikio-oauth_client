require "oauth2"

require "zaikio/oauth_client/error"
require "zaikio/oauth_client/engine"
require "zaikio/oauth_client/configuration"
require "zaikio/oauth_client/authenticatable"

module Zaikio
  module OAuthClient # rubocop:disable Metrics/ModuleLength
    class << self
      def configure
        @configuration ||= Configuration.new
        yield(configuration)
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def client_name
        Thread.current[:zaikio_oauth_client_name]
      end

      def client_name=(new_value)
        Thread.current[:zaikio_oauth_client_name] = new_value
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

      def with_client(new_client_name)
        original_client_name = client_name

        self.client_name = new_client_name

        yield
      ensure
        self.client_name = original_client_name
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

      # Finds active access token, using the DB or Client Credentials flow
      #   * It searches in the DB for an active access token
      #   * If the token does not exist, we'll get a new one using the client_credentials flow
      def get_access_token(bearer_id:, client_name: nil, bearer_type: "Person", scopes: nil, valid_for: 30.seconds)
        client_config = client_config_for(client_name || self.client_name)
        scopes ||= client_config.default_scopes_for(bearer_type)

        token = find_usable_access_token(client_name: client_config.client_name,
                                         bearer_type: bearer_type,
                                         bearer_id: bearer_id,
                                         requested_scopes: scopes,
                                         valid_for: valid_for)

        token ||= fetch_new_token(client_config: client_config,
                                  bearer_type: bearer_type,
                                  bearer_id: bearer_id,
                                  scopes: scopes)
        token
      end

      # This method can be used to find an active access token by id.
      # It might refresh the access token to get an active one.
      def find_active_access_token(id, valid_for: 30.seconds)
        return unless id

        if Rails.env.test?
          access_token = TestHelper.find_active_access_token(id)
          return access_token if access_token
        end

        access_token = Zaikio::AccessToken.valid(valid_for.from_now).or(
          Zaikio::AccessToken.valid_refresh(valid_for.from_now)
        ).find_by(id: id)
        access_token = access_token.refresh! if access_token&.expired?

        access_token
      end

      # Finds active access token with matching criteria for bearer and scopes.
      def find_usable_access_token(client_name:, bearer_type:, bearer_id:, requested_scopes:, valid_for: 30.seconds) # rubocop:disable Metrics/MethodLength
        configuration.logger.debug "Try to fetch token for client_name: #{client_name}, " \
                                   "bearer #{bearer_type}/#{bearer_id}, requested_scopes: #{requested_scopes}"

        fetch_access_token = lambda {
          Zaikio::AccessToken
            .where(audience: client_name)
            .by_bearer(
              bearer_type: bearer_type,
              bearer_id: bearer_id,
              requested_scopes: requested_scopes
            )
            .valid(valid_for.from_now)
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
          requested_scopes: scopes,
          include_refresh_token: false
          # Do not store refresh token on client credentials flow
          # https://docs.zaikio.com/changelog/2022-08-09_client-credentials-drop-refresh-token.html
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
