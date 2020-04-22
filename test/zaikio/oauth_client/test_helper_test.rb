require "test_helper"
require "zaikio/oauth_client/test_helper"

class Zaikio::OAuthClient::TestHelperTest < ActionDispatch::IntegrationTest
  include Zaikio::OAuthClient::TestHelper

  test "sets cookie correctly" do
    person = OpenStruct.new(id: "my-id")
    logged_in_as(person)

    get "/"

    jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    assert_equal "my-id", jar.encrypted["zaikio_person_id"]
  end
end
