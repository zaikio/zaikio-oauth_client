require "test_helper"
require "zaikio/oauth_client/test_helper"

class Zaikio::OAuthClient::TestHelperTest < ActionDispatch::IntegrationTest
  test "sets cookie correctly" do
    person = Struct.new(:id).new("my-id")
    logged_in_as(person)

    get "/"

    assert_equal "Hello my-id", response.body
    assert_equal "my-id", @controller.session[:zaikio_person_id]
    assert_equal "AT:warehouse:my-id", @controller.session[:zaikio_access_token_id]
    access_token = Zaikio::OAuthClient.find_active_access_token(@controller.session[:zaikio_access_token_id])
    assert_equal "my-id", access_token.bearer_id
    assert_equal "Person", access_token.bearer_type
    assert_equal "AT:warehouse:my-id", access_token.id
    assert_not access_token.expired?
  end
end
