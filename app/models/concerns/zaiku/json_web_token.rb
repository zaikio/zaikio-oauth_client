require 'jwt'
require 'open-uri'

module Zaiku::JSONWebToken
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

  def token=(token)
    super
    token_data = decode_jwt

    self.id = token_data['jti']
    self.expires_at = DateTime.strptime(token_data['exp'].to_s,'%s')
  end

  private

  def retrieve_jwt_keys(invalidate: false)
    if @@keys.is_a?(Hash) && !invalidate
      return @@keys
    else
      result = open(Zaiku.directory_url + '/api/v1/jwt_public_keys.json').read
      @@keys = JSON.parse(result).deep_symbolize_keys
    end
  end

  def decode_jwt
    JWT.decode(
      self.token,
      nil,
      true,
      {
        # We verify the expiration ourselves
        exp_leeway: 1000.years.to_i,
        algorithms: ['RS256'],
        jwks: -> (options) { retrieve_jwt_keys(invalidate: options[:invalidate]) }
      }
    ).first
  end
end
