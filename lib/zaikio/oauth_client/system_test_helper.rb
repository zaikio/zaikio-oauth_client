require_relative "./test_helper"

module Zaikio
  module OAuthClient
    module SystemTestHelper
      include ::Zaikio::OAuthClient::TestHelper

      def set_session(key, value)
        visit "/zaikio/oauth_client/test_helper/session?#{{ key: key, id: value }.to_query}"
      end

      def get_session(key)
        visit "/zaikio/oauth_client/test_helper/get_session?#{{ key: key }.to_query}"
        page.text
      end
    end
  end
end
