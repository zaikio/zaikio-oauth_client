require "jwt"
require "zaikio/jwt_auth"

module Zaikio
  class AccessToken < ApplicationRecord
    self.table_name = "zaikio_access_tokens"

    # Encryption
    encrypts :token
    encrypts :refresh_token

    def self.build_from_access_token(access_token, requested_scopes: nil, include_refresh_token: true)
      return if access_token.nil?

      payload = JWT.decode(access_token.token, nil, false).first rescue {} # rubocop:disable Style/RescueModifier
      scopes = access_token.params["scope"].split(",")
      new(
        id: payload["jti"],
        bearer_type: access_token.params["bearer"]["type"],
        bearer_id: access_token.params["bearer"]["id"],
        audience: access_token.params["audiences"].first,
        token: access_token.token,
        refresh_token: (access_token.refresh_token if include_refresh_token),
        expires_at: Time.strptime(access_token.expires_at.to_s, "%s"),
        scopes: scopes,
        requested_scopes: requested_scopes || scopes
      )
    end

    def self.refresh_token_valid_for
      7.days
    end

    # Scopes
    scope :valid, lambda { |valid_until = Time.current|
      where("expires_at > :valid_until", valid_until: valid_until)
        .where.not(id: Zaikio::JWTAuth.revoked_token_ids)
    }
    scope :with_invalid_refresh_token, lambda {
      where("created_at <= ?", Time.current - Zaikio::AccessToken.refresh_token_valid_for)
    }
    scope :valid_refresh, lambda { |valid_until = Time.current|
      where("expires_at <= :valid_until AND created_at > :created_at_max",
            valid_until: valid_until,
            created_at_max: valid_until - refresh_token_valid_for)
        .where.not(refresh_token: nil)
        .where.not(id: Zaikio::JWTAuth.revoked_token_ids)
    }
    scope :by_bearer, lambda { |bearer_id:, requested_scopes: [], bearer_type: "Person"|
      where(bearer_type: bearer_type, bearer_id: bearer_id)
        .where("requested_scopes @> ARRAY[?]::varchar[]", requested_scopes)
    }
    scope :usable, lambda { |valid_until: Time.current, **options|
      by_bearer(**options).valid(valid_until).or(
        by_bearer(**options).valid_refresh
      ).order(expires_at: :desc)
    }

    def expired?
      expires_at < Time.current
    end

    def organization?
      bearer_type == "Organization"
    end

    def expires_in
      (expires_at - Time.current).to_i
    end

    def bearer_klass
      return unless Zaikio.const_defined?("Hub::Models", false)

      if Zaikio::Hub::Models.configuration.respond_to?(:"#{bearer_type.underscore}_class_name")
        Zaikio::Hub::Models.configuration.public_send(:"#{bearer_type.underscore}_class_name").constantize
      else
        "Zaikio::#{bearer_type}".constantize
      end
    end

    def refresh!
      return unless refresh_token?

      Zaikio::OAuthClient.with_oauth_scheme(:basic_auth) do
        refreshed_token = OAuth2::AccessToken.from_hash(
          Zaikio::OAuthClient.for(audience),
          attributes.slice("token", "refresh_token")
        ).refresh!

        destroy

        self.class.build_from_access_token(refreshed_token, requested_scopes: requested_scopes).tap(&:save!)
      end
    rescue OAuth2::Error => e
      raise unless e.code == "invalid_grant"

      destroy
      nil
    end

    def revoke!
      return unless Zaikio.const_defined?("Hub::RevokedAccessToken", false)

      Zaikio::Hub.with_token(token) do
        Zaikio::Hub::RevokedAccessToken.create
      end
    rescue Zaikio::ConnectionError => e
      Zaikio::OAuthClient.configuration.logger.warn "Access Token #{id} could not be revoked: #{e.message}"
    end
  end
end
