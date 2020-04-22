module Zaikio
  module OAuthClient
    module TestHelper
      extend ActiveSupport::Concern

      def logged_in_as(person)
        # We need to manually encrypt the value since the tests cookie jar does not
        # support encrypted or signed cookies
        encrypted_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
        encrypted_cookies.encrypted[:zaikio_person_id] = person.id

        cookies["zaikio_person_id"] = encrypted_cookies["zaikio_person_id"]
      end
    end
  end
end
