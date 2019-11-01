require "zaiku/engine"
require "zaiku/jeweler"
require 'oauth2'

module Zaiku
  # OAuth2 Settings
  mattr_accessor :client_id
  mattr_accessor :client_secret
  mattr_accessor :directory_url

  def self.oauth_client(options = {})
    OAuth2::Client.new(
      Zaiku.client_id,
      Zaiku.client_secret,
      {
        site: Zaiku.directory_url,
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/access_token',
        connection_opts: { headers: { 'Accept': 'application/json' } }
      }.merge(options)
    )
  end

  def self.directory(token:)
    Zaiku::Remote::Client.new(token: token)
  end
end
