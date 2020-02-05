require 'test_helper'

module Zaikio
  module Remote
    class AccessTokenTest < ActiveSupport::TestCase
      setup do
        @token = Zaikio::Remote::AccessToken.initialize_by_oauth_access_token(
          access_token: zaikio_access_tokens(:fgalli),
          bearer: nil
        )
      end

      test 'retrieves public keys for JWT from a given endpoint' do
        @token.send(:retrieve_jwt_keys)

        assert_instance_of Hash, Zaikio::Remote::AccessToken.class_variable_get(:@@keys)
        assert_equal Zaikio::Remote::AccessToken.class_variable_get(:@@keys)[:keys].size, 1
      end

      test 'decodes a JSON web token' do
        assert_instance_of Hash, @token.send(:decode_jwt)
      end

      test 'fills own attributes with data from token upon token assignment' do
        assert_equal '57ab5e51-3b20-4900-8a14-6420dabfcddb', @token.id
        assert_equal DateTime.parse('Sat, 5 Feb 3020 13:14:40'), @token.expires_at
      end
    end
  end
end
