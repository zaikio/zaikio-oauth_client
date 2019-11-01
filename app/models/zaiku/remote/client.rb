require 'active_support/security_utils'

require 'jeweler/client'
require 'jeweler/connection'
require 'jeweler/writeable'
require 'jeweler/resource'
require 'jeweler/singleton_resource'
require 'jeweler/finders'
require 'jeweler/collection'
require 'jeweler/errors'

module Zaiku
  module Remote
    class Client
      include Jeweler::Client

      base_collections :sites

      def initialize(token:)
        token = refresh_token_if_expired(token)
        super(
          host: Zaiku.directory_url,
          token: token,
          base_uri: '/api/v1/'
        )
      end

      def person
        @person ||= Zaiku::Remote::Person.new(
          self,
          self.perform_request(:get, '/person')
        ).tap do |person|
          person.extend(Jeweler::SingletonResource)
        end
      end

      def refresh_token_if_expired(token)
        access_token = Zaiku::AccessToken.find_by(token: token)
        if access_token&.expired?
          access_token.refresh!.token
        else
          token
        end
      end
    end
  end
end
