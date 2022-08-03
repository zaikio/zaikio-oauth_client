module Zaikio
  module OAuthClient
    module TestHelper
      extend ActiveSupport::Concern

      VirtualAccessToken = Struct.new(:id, :bearer_id, :bearer_type, :audience, :expired?, keyword_init: true)

      class << self
        def find_active_access_token(id)
          return unless id.to_s.starts_with?("AT:")

          _, audience, person_id = id.split(":")

          VirtualAccessToken.new(
            id: id,
            bearer_id: person_id,
            audience: audience,
            bearer_type: "Person",
            expired?: false
          )
        end
      end

      class TestSessionController < ActionController::Base # rubocop:disable Rails/ApplicationController
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

      included do
        # This is needed as it is not possible to set sesison values in an ActionDispatch::IntegrationTest
        # This creates a dummy controller to set the session
        Rails.application.routes.disable_clear_and_finalize = true # Keep existing routes
        Rails.application.routes.draw do
          get "/zaikio/oauth_client/test_helper/get_session", to: "zaikio/oauth_client/test_helper/test_session#show"
          get "/zaikio/oauth_client/test_helper/session", to: "zaikio/oauth_client/test_helper/test_session#create"
        end
      end

      def get_session(key)
        get "/zaikio/oauth_client/test_helper/get_session", params: { key: key }

        if response.status == 204
          nil
        else
          response.body
        end
      end

      def set_session(key, value)
        get "/zaikio/oauth_client/test_helper/session", params: { id: value, key: key }
      end

      def logged_in_as(person, access_token: nil, client_name: nil)
        client_name ||= Zaikio::OAuthClient.client_name ||
                        Zaikio::OAuthClient.configuration.all_client_names.first
        set_session(
          :zaikio_access_token_id,
          access_token&.id || "AT:#{client_name}:#{person.id}"
        )

        # Deprecated please use zaikio_access_token_id
        set_session(:zaikio_person_id, person.id)
      end
    end
  end
end
