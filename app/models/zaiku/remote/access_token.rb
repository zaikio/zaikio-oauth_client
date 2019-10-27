module Zaiku
  module Remote
    class AccessToken
      include Zaiku::JSONWebToken
      include Zaiku::Localize

      attr_accessor :id, :bearer, :token, :refresh_token, :expires_at

      class << self
        def initialize_by_oauth_access_token(access_token:, bearer:)
          self.new.tap do |object|
            object.token = access_token.token
            token_data = object.send(:decode_jwt)

            object.id = token_data['jti']
            object.refresh_token = access_token.refresh_token
            object.bearer = bearer
            object.expires_at = DateTime.strptime(token_data['exp'].to_s,'%s')
          end
        end
      end

      def attributes
        Hash.new.tap do |attributes|
          %w( id bearer token refresh_token expires_at ).each do |attribute|
            attributes[attribute] = send(attribute)
          end
        end
      end
    end
  end
end
