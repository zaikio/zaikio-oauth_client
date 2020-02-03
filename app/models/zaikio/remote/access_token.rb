module Zaikio
  module Remote
    class AccessToken
      include Zaikio::JSONWebToken
      include Zaikio::Localize

      attr_accessor :id, :bearer, :bearer_id, :bearer_type,
        :token, :refresh_token, :expires_at

      class << self
        def initialize_by_oauth_access_token(access_token:, bearer:)
          self.new.tap do |object|
            object.token = access_token.token
            token_data = object.send(:decode_jwt)

            object.id = token_data['jti']
            object.refresh_token = access_token.refresh_token
            object.bearer = bearer
            object.bearer_id = bearer&.id
            object.bearer_type = bearer&.class&.name
            object.expires_at = DateTime.strptime(token_data['exp'].to_s,'%s')
          end
        end
      end
    end
  end
end
