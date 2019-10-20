require 'test_helper'

module Zaiku
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "a person is redirect to the ZAIKU directory OAuth flow" do
      get new_session_url

      params = {
        client_id: Zaiku::Directory.client_id,
        redirect_uri: new_callback_url,
        response_type: 'code'
      }

      assert_redirected_to "#{Zaiku.approve_sessions_url}/oauth/authorize?#{params.to_query}"
    end
  end
end
