require "test_helper"
require "zaikio/oauth_client/test_helper"

class Zaikio::OAuthClient::TestHelperTest < ActionDispatch::IntegrationTest
  test "sets cookie correctly" do
    person = Struct.new(:id).new("my-id")
    logged_in_as(person)

    get "/"

    assert_equal "Hello my-id", response.body
    assert_equal "my-id", @controller.session[:zaikio_person_id]
  end
end
