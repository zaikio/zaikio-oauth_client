require 'test_helper'

module Zaiku
  class AccessTokenTest < ActiveSupport::TestCase
    test 'retrieves public keys for JWT from a given endpoint' do
      token = AccessToken.new
      token.send(:retrieve_jwt_keys)

      assert_instance_of Hash, AccessToken.class_variable_get(:@@keys)
      assert_equal AccessToken.class_variable_get(:@@keys)[:keys].size, 1
    end

    test 'decodes a JSON web token' do
      token = zaiku_access_tokens(:fgalli)
      assert_instance_of Hash, token.send(:decode_jwt)
    end

    test 'fills own attributes with data from token upon token assignment' do
      token = AccessToken.new
      token.token = zaiku_access_tokens(:fgalli).token

      assert_equal '0aa4ae0a-ede4-45c7-b5d9-bf2e072b2fd7', token.id
      assert_equal DateTime.parse('Fri, 25 Oct 2019 17:51:57'), token.expires_at
    end
  end
end
