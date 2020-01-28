require 'jwt'
require 'open-uri'

module Zaikio::JSONWebToken
  extend ActiveSupport::Concern

  included do
    @@keys = nil
  end

  def self.keys
    return @@keys unless @@keys.empty?
    @@keys = []
  end

  def self.invalidate_keys!
    @@keys = []
  end

  private

  def retrieve_jwt_keys(invalidate: false)
    if @@keys.is_a?(Hash) && !invalidate
      return @@keys
    else
      result = open(Zaikio.directory_url + '/api/v1/jwt_public_keys.json').read
      @@keys = JSON.parse(result).deep_symbolize_keys
    end
  end

  def decode_jwt
    JWT.decode(
      self.token,
      nil,
      true,
      {
        # A jitter of 1 second, especially during testing is fine
        nbf_leeway: 2.seconds.to_i,
        # We verify the expiration ourselves
        exp_leeway: 1000.years.to_i,
        algorithms: ['RS256'],
        jwks: -> (options) { retrieve_jwt_keys(invalidate: options[:invalidate]) }
      }
    ).first
  end
end
