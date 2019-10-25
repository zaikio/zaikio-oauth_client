require 'test_helper'

module Zaiku
  class AccessTokenTest < ActiveSupport::TestCase
    test "retrieves public keys for JWT from a given endpoint" do
      token = AccessToken.new
      token.send(:retrieve_jwt_keys)

      assert_equal AccessToken.class_variable_get(:@@keys).size, 1
      assert_instance_of JWT::JWK::RSA, AccessToken.class_variable_get(:@@keys).first
    end
  end
end
