module Zaikio
  module OAuthClient
    module TestHelper
      extend ActiveSupport::Concern

      class TestSessionController < ActionController::Base
        def show
          if session[params[:key]].nil?
            head :no_content
          else
            render plain: session[params[:key]]
          end
        end

        def create
          session[params[:key]] = params[:id]

          head :ok
        end
      end

      def get_session(key)
        # This is needed as it is not possible to set sesison values in an ActionDispatch::IntegrationTest
        # This creates a dummy controller to set the session
        Rails.application.routes.disable_clear_and_finalize = true # Keep existing routes
        Rails.application.routes.draw do
          get "/zaikio/oauth_client/test_helper/get_session", to: "zaikio/oauth_client/test_helper/test_session#show"
        end

        get "/zaikio/oauth_client/test_helper/get_session", params: { key: key }

        if response.status == 204
          nil
        else
          response.body
        end
      end

      def set_session(key, value)
        # This is needed as it is not possible to set sesison values in an ActionDispatch::IntegrationTest
        # This creates a dummy controller to set the session
        Rails.application.routes.disable_clear_and_finalize = true # Keep existing routes
        Rails.application.routes.draw do
          get "/zaikio/oauth_client/test_helper/session", to: "zaikio/oauth_client/test_helper/test_session#create"
        end

        get "/zaikio/oauth_client/test_helper/session", params: { id: value, key: key }
      end

      def logged_in_as(person)
        set_session(:zaikio_person_id, person.id)
      end
    end
  end
end
