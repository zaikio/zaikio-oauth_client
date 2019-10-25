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

      def initialize(token:)
        super(
          host: Zaiku.directory_url,
          token: token,
          base_uri: '/api/v1'
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
    end
  end
end
