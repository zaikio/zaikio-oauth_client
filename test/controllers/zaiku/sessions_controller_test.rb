require 'test_helper'

module Zaiku
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "an unknown user is redirected to the ZAIKU directory OAuth flow" do
      get new_session_url

      params = {
        client_id: Zaiku.client_id,
        redirect_uri: approve_sessions_url,
        response_type: 'code'
      }

      assert_redirected_to "#{Zaiku.directory_url}/oauth/authorize?#{params.to_query}"
    end
  end
end
