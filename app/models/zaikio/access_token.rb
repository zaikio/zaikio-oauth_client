module Zaikio
  class AccessToken < ApplicationRecord
    # Associations
    belongs_to :bearer, polymorphic: true

    # Scopes
    scope :valid, -> { where('expires_at > :now', now: DateTime.now) }

    def expired?
      expires_at < DateTime.now
    end

    def expires_in
      (expires_at - DateTime.now).to_i
    end

    def refresh!
      refreshed_token = OAuth2::AccessToken.from_hash(
        Zaikio.oauth_client({auth_scheme: :basic_auth}),
        attributes
      ).refresh!

      transaction do
        # Save the new access token for further requests
        new_access_token = Zaikio::Remote::AccessToken.initialize_by_oauth_access_token(
          access_token: refreshed_token,
          bearer: bearer
        ).to_local_access_token

        # Destroy old access token that was used for refreshing
        destroy if new_access_token.save!

        return new_access_token
      end
    end
  end
end
