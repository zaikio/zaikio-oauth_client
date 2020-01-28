require 'test_helper'

module Zaikio
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "an unknown user is redirected to the Zaikio directory OAuth flow" do
      get new_session_url

      params = {
        client_id: Zaikio.client_id,
        redirect_uri: approve_sessions_url,
        response_type: 'code'
      }

      assert_redirected_to "#{Zaikio.directory_url}/oauth/authorize?#{params.to_query}"
    end
  end
end
