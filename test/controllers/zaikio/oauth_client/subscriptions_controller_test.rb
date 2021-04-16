require "test_helper"

module Zaikio
  module OAuthClient
    class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
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

      test "an unknown org is redirected to the Zaikio OAuth subscription flow" do
        get zaikio_oauth_client.new_subscription_path

        params = {
          client_id: "abc",
          redirect_uri: zaikio_oauth_client.approve_connection_url,
          redirect_with_error: 1,
          response_type: "code",
          scope: "Org.subscription_create"
        }

        assert_redirected_to "http://hub.zaikio.test/oauth/authorize?#{params.to_query}"
      end

      test "with a ?plan parameter it is redirected to the Zaikio OAuth subscription flow" do
        get zaikio_oauth_client.new_subscription_path(plan: "free")

        params = {
          client_id: "abc",
          redirect_uri: zaikio_oauth_client.approve_connection_url,
          redirect_with_error: 1,
          response_type: "code",
          scope: "Org.subscription_create.free"
        }

        assert_redirected_to "http://hub.zaikio.test/oauth/authorize?#{params.to_query}"
      end

      test "with a ?organization_id parameter it includes that ID in the scope" do
        get zaikio_oauth_client.new_subscription_path(organization_id: "a4cd0243-2575-4d3f-b143-4c85f959808d")

        params = {
          client_id: "abc",
          redirect_uri: zaikio_oauth_client.approve_connection_url,
          redirect_with_error: 1,
          response_type: "code",
          scope: "Org/a4cd0243-2575-4d3f-b143-4c85f959808d.subscription_create"
        }

        assert_redirected_to "http://hub.zaikio.test/oauth/authorize?#{params.to_query}"
      end
    end
  end
end
