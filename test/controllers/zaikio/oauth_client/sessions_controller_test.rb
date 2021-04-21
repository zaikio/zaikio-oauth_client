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

        redirect_url = URI.parse(response.headers["Location"])
        assert_equal "hub.zaikio.test", redirect_url.host
        assert_equal "/oauth/authorize", redirect_url.path

        query = URI.decode_www_form(redirect_url.query).to_h
        assert_equal query["client_id"], "abc"
        assert_equal query["redirect_uri"], zaikio_oauth_client.approve_session_url
        assert_equal query["response_type"], "code"
        assert_equal query["scope"], "directory.person.r"
        assert_equal query["redirect_with_error"], "1"

        assert query["state"].present?
      end

      test "additional permitted OAuth params are passed into the Zaikio OAuth flow" do
        get zaikio_oauth_client.new_session_path(show_signup: true,
                                                 force_login: true,
                                                 state: "entropy",
                                                 unknown_param: :no)

        params = {
          client_id: "abc",
          redirect_uri: zaikio_oauth_client.approve_session_url,
          redirect_with_error: 1,
          response_type: "code",
          scope: "directory.person.r",
          show_signup: true,
          force_login: true,
          state: "entropy"
        }

        assert_redirected_to "http://hub.zaikio.test/oauth/authorize?#{params.to_query}"
      end

      test "Shows error and redirects if redirect flow wasn't successful" do
        get approve_session_path(error: "invalid_request", error_description: "My Error")

        assert_redirected_to main_app.root_path
        assert_match "invalid_request", flash[:alert]
        assert_match "My Error", flash[:alert]
      end

      test "Raises exception if scope was invalid" do
        assert_raise Zaikio::OAuthClient::InvalidScopesError do
          get approve_session_path(error: "invalid_scope", error_description: "malformed_scope")
        end
      end

      test "Shows no error but redirects if user cancelled flow" do
        get approve_session_path(error: "access_denied")

        assert_redirected_to main_app.root_path
        assert_nil flash[:alert]
      end

      test "Does code grant flow" do
        set_session(:origin, "/?a=b")

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
            "scope" => "directory.person.r",
            "audiences" => ["warehouse"],
            "expires_in" => 600,
            "bearer" => {
              "id": "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7",
              "type": "Person"
            }
          }.to_json, headers: { "Content-Type" => "application/json" })

        get zaikio_oauth_client.approve_session_path(code: "mycode")
        access_token = Zaikio::AccessToken.order(:created_at).last
        assert_redirected_to "/?a=b"
        follow_redirect!
        assert_nil get_session(:origin)
        assert_equal "29b276b7-c0fa-4514-a5b1-c0fb4ee40fa7", get_session(:zaikio_person_id)
        assert_equal access_token.id, get_session(:zaikio_access_token_id)

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
