require "zaikio/engine"
require "zaikio/jeweler"
require 'oauth2'

module Zaikio
  # OAuth2 Settings
  mattr_accessor :client_id
  mattr_accessor :client_secret
  mattr_accessor :directory_url

  def self.oauth_client(options = {})
    OAuth2::Client.new(
      Zaikio.client_id,
      Zaikio.client_secret,
      {
        site: Zaikio.directory_url,
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
