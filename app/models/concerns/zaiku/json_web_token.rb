require 'jwt'

module Zaiku::JSONWebToken
  extend ActiveSupport::Concern

  included do
    @@keys = Array.new
  end

  def self.keys
    return @@keys unless @@keys.empty?
    @@keys = []
  end

  def self.invalidate_keys!
    @@keys = []
  end

  def json_web_token_data
    @jwt ||= decode_jwt
  end

  private

  def decode_jwt
    jwt_data = Hash.new
    jwt_decode_error = nil

    # If we have many keys, try to find the one that decodes the JWT
    Zaiku::JSONWebToken.keys.each do |key|
      jwt_data = JWT.decode(self.token, key, true, algorithm: 'RS256').first

    rescue JWT::DecodeError => error
      jwt_decode_error = error
      next
    end

    # If we could decode the JWT we will return it, otherwise we will raise
    # the decoding error and invalidate all ours keys, so on the next attempt
    # we try to receive new ones
    if jwt_data.keys.any?
      return jwt_data
    else
      Zaiku::JSONWebToken.invalidate_keys!
      raise jwt_decode_error
    end
  end
end
