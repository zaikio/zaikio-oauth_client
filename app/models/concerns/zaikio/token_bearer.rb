module Zaikio::TokenBearer
  extend ActiveSupport::Concern

  included do
    # Associations
    has_many :access_tokens, as: :bearer, class_name: 'Zaikio::AccessToken'
  end

  def last_valid_or_expired_token
    access_tokens.valid&.first&.token || access_tokens.last.token
  end
end
