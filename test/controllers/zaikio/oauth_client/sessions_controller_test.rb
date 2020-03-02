require 'test_helper'

module Zaikio
  module OAuthClient
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      test "an unknown user is redirected to the Zaikio directory OAuth flow" do
        get new_session_url

        params = {
          client_id: Zaikio::OAuthClient.client_id,
          redirect_uri: approve_sessions_url,
          response_type: 'code',
          scope: 'directory.person.r'
        }

        assert_redirected_to "#{Zaikio::OAuthClient.directory_url}/oauth/authorize?#{params.to_query}"
      end
    end
  end
end
