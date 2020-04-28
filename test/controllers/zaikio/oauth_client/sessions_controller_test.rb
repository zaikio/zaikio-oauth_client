require "test_helper"

module Zaikio
  module OAuthClient
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      def setup
        Zaikio::OAuthClient.configure do |config|
          config.environment = :test
          config.register_client :warehouse do |warehouse|
            warehouse.client_id = "abc"
            warehouse.client_secret = "secret"
            warehouse.default_scopes = %w[directory.person.r]

            warehouse.register_organization_connection do |org|
              org.default_scopes = %w[directory.organization.r]
            end
          end
        end
      end

      test "an unknown user is redirected to the Zaikio OAuth flow" do
        get zaikio_oauth_client.new_session_path

        params = {
          client_id: "abc",
          redirect_uri: zaikio_oauth_client.approve_session_url,
          response_type: "code",
          scope: "directory.person.r"
        }

        assert_redirected_to "http://directory.zaikio.test/oauth/authorize?#{params.to_query}"
      end

      test "Does code grant flow" do
        my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
        my_cookies.encrypted[:origin] = "/my-redirect"
        cookies[:origin] = my_cookies[:origin]

        stub_request(:post, "http://directory.zaikio.test/oauth/access_token")
          .with(
            body: {
              "client_id" => "abc",
              "client_secret" => "secret",
              "code" => "mycode",
              "grant_type" => "authorization_code"
            },
            headers: {
              "Accept" => "application/json"
            }
          )
          .to_return(status: 200, body: {
            "access_token" => "749ceefd1f7909a1773501e0bc57d5b2",
            "refresh_token" => "be4ae927cf49466293049c993ad911b2",
            "token_type" => "bearer",
            "scope" => "directory.person.r",
            "audiences" => ["warehouse"],
            "expires_in" => 600,
            "bearer" => {
              "id": "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7",
              "type": "Person"
            }
          }.to_json, headers: { "Content-Type" => "application/json" })

        get approve_session_path(code: "mycode")
        access_token = Zaikio::AccessToken.order(:created_at).last
        jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
        assert_nil jar.encrypted["origin"]
        assert_equal "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7", jar.encrypted["zaikio_person_id"]
        assert_equal access_token.id, jar.encrypted["zaikio_access_token_id"]
        assert_redirected_to "/my-redirect"

        assert_equal "Person", access_token.bearer_type
        assert_equal "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7", access_token.bearer_id
        assert_equal "warehouse", access_token.audience
        assert_equal "749ceefd1f7909a1773501e0bc57d5b2", access_token.token
        assert_equal "be4ae927cf49466293049c993ad911b2", access_token.refresh_token
        assert_equal %w[directory.person.r], access_token.scopes

        delete zaikio_oauth_client.session_path(client_name: "warehouse")
        jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
        assert_nil jar.encrypted["zaikio_person_id"]
        assert_nil jar.encrypted["zaikio_access_token_id"]
        assert_redirected_to "/"
      end
    end
  end
end
