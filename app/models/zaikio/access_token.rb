require "jwt"
require "zaikio/jwt_auth"

module Zaikio
  class AccessToken < ApplicationRecord
    self.table_name = "zaikio_access_tokens"

    def self.build_from_access_token(access_token) # rubocop:disable Metrics/AbcSize
      payload = JWT.decode(access_token.token, nil, false).first rescue {} # rubocop:disable Style/RescueModifier
      new(
        id: payload["jti"],
        bearer_type: access_token.params["bearer"]["type"],
        bearer_id: access_token.params["bearer"]["id"],
        audience: access_token.params["audiences"].first,
        token: access_token.token,
        refresh_token: access_token.refresh_token,
        expires_at: Time.strptime(access_token.expires_at.to_s, "%s"),
        scopes: access_token.params["scope"].split(",")
      )
    end

    def self.refresh_token_valid_for
      7.days
    end

    # Scopes
    scope :valid, lambda {
      where("expires_at > :now", now: Time.current)
        .where.not(id: Zaikio::JWTAuth.revoked_token_ids)
    }
    scope :with_invalid_refresh_token, lambda {
      where("created_at <= ?", Time.current - Zaikio::AccessToken.refresh_token_valid_for)
    }
    scope :valid_refresh, lambda {
      where("expires_at <= :now AND created_at > :created_at_max",
            now: Time.current,
            created_at_max: Time.current - refresh_token_valid_for)
        .where("refresh_token IS NOT NULL")
        .where.not(id: Zaikio::JWTAuth.revoked_token_ids)
    }
    scope :by_bearer, lambda { |bearer_id:, scopes: [], bearer_type: "Person"|
      where(bearer_type: bearer_type, bearer_id: bearer_id)
        .where("scopes @> ARRAY[?]::varchar[]", scopes)
    }
    scope :usable, lambda { |options|
      by_bearer(**options).valid.or(by_bearer(**options).valid_refresh)
                          .order(expires_at: :desc)
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
      return unless Zaikio.const_defined?("Directory::Models")

      if Zaikio::Hub::Models.configuration.respond_to?(:"#{bearer_type.underscore}_class_name")
        Zaikio::Hub::Models.configuration.public_send(:"#{bearer_type.underscore}_class_name").constantize
      else
        "Zaikio::#{bearer_type}".constantize
      end
    end

    def refresh!
      Zaikio::OAuthClient.with_oauth_scheme(:basic_auth) do
        refreshed_token = OAuth2::AccessToken.from_hash(
          Zaikio::OAuthClient.for(audience),
          attributes.slice("token", "refresh_token")
        ).refresh!

        access_token = self.class.build_from_access_token(refreshed_token)

        transaction { destroy if access_token.save! }

        access_token
      end
    end
  end
end
