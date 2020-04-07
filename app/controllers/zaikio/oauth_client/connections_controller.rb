module Zaikio
  module OAuthClient
    class ConnectionsController < ApplicationController
      include Zaikio::OAuthClient::Authenticatable

      private

      def approve_url(client_name = nil)
        approve_connection_url(client_name)
      end

      def use_org_config?
        true
      end
    end
  end
end
