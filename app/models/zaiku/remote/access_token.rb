module Zaiku
  module Remote
    class AccessToken
      include Zaiku::JSONWebToken
      attr_accessor :bearer, :token

      def initialize(bearer:, token: nil)
        @bearer, @token = bearer, token
      end

      def to_local_access_token
        jwt_token_data = self.json_web_token_data

        bearer.access_tokens.new(
          token: @token.token,
          expires_at: DateTime.strptime(token.expires_at.to_s, '%s'),
          refresh_token: refresh_token
        )
      end
    end
  end
end
