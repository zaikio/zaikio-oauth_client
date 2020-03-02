require "zaikio/oauth_client/engine"
require "zaikio/jeweler"
require 'oauth2'

module Zaikio
  module OAuthClient
    # OAuth2 Settings
    mattr_accessor :client_id
    mattr_accessor :client_secret
    mattr_accessor :directory_url

    def self.oauth_client(options = {})
      OAuth2::Client.new(
        Zaikio::OAuthClient.client_id,
        Zaikio::OAuthClient.client_secret,
        {
          site: Zaikio::OAuthClient.directory_url,
          authorize_url: 'oauth/authorize',
          token_url: 'oauth/access_token',
          connection_opts: { headers: { 'Accept': 'application/json' } }
        }.merge(options)
      )
    end

    def self.directory(token:)
      Zaikio::Remote::Client.new(token: token)
    end
  end
end
