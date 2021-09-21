module Zaikio
  module OAuthClient
    class ConnectionsController < ApplicationController
      include Zaikio::OAuthClient::Authenticatable

      private

      def new_path(options = {})
        zaikio_oauth_client.new_connection_path(options)
      end

      def approve_url(client_name = nil)
        zaikio_oauth_client.approve_connection_url(client_name)
      end

      def use_org_config?
        true
      end
    end
  end
end
