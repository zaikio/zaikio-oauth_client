require "test_helper"

module Zaikio
  module OAuthClient
    class ConnectionsControllerTest < ActionDispatch::IntegrationTest
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

      test "an unknown org is redirected to the Zaikio OAuth flow" do
        get zaikio_oauth_client.new_connection_path(state: "")

        params = {
          client_id: "abc",
          redirect_uri: zaikio_oauth_client.approve_connection_url,
          response_type: "code",
          scope: "Org.directory.organization.r",
          state: "",
          lang: "en"
        }

        assert_redirected_to "http://hub.zaikio.test/oauth/authorize?#{params.to_query}"
      end

      test "a known org is redirected to the Zaikio OAuth flow" do
        get zaikio_oauth_client.new_connection_path(organization_id: "123", state: "yes-me")

        params = {
          client_id: "abc",
          redirect_uri: approve_connection_url,
          response_type: "code",
          scope: "Org/123.directory.organization.r",
          state: "yes-me",
          lang: "en"
        }

        assert_redirected_to "http://hub.zaikio.test/oauth/authorize?#{params.to_query}"
      end

      test "without passing a ?state parameter, it sets a high-entropy string cookie" do
        get zaikio_oauth_client.new_connection_path

        current_response = response

        assert get_session(:state).present?
        assert get_session(:state).length > 30

        authorize_url = URI.parse(current_response.headers["Location"])
        authorize_params = URI.decode_www_form(authorize_url.query).to_h
        assert_equal get_session(:state), authorize_params["state"]
      end

      test "Does code grant flow" do
        set_session(:origin, "/my-redirect")

        stub_request(:post, "http://hub.zaikio.test/oauth/access_token")
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
            "scope" => "directory.organization.r",
            "audiences" => ["warehouse"],
            "expires_in" => 600,
            "bearer" => {
              id: "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7",
              type: "Organization"
            }
          }.to_json, headers: { "Content-Type" => "application/json" })

        get zaikio_oauth_client.approve_connection_path(code: "mycode")
        access_token = Zaikio::AccessToken.order(:created_at).last
        jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
        assert_nil jar.encrypted["origin"]
        assert_nil jar.encrypted["zaikio_person_id"]
        assert_nil jar.encrypted["zaikio_access_token_id"]
        assert_redirected_to "/my-redirect"

        assert_equal "Organization", access_token.bearer_type
        assert_equal "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7", access_token.bearer_id
        assert_equal "warehouse", access_token.audience
        assert_equal "749ceefd1f7909a1773501e0bc57d5b2", access_token.token
        assert_equal "be4ae927cf49466293049c993ad911b2", access_token.refresh_token
        assert_equal %w[directory.organization.r], access_token.scopes
      end

      test "checks ?state parameter when approving with encrypted :state cookie" do
        set_session(:state, "not-me")

        get zaikio_oauth_client.approve_connection_path(code: "mycode", state: "yes-me")

        assert_redirected_to "/"
        assert_match "An error occurred during login: invalid_state", flash[:alert]
      end
    end
  end
end
