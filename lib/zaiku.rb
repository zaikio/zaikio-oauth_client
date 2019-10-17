require "zaiku/engine"

module Zaiku
  # OAuth2 Settings
  mattr_accessor :client_id
  mattr_accessor :client_secret
  mattr_accessor :directory_url
end
