module Zaikio::TokenBearer
  extend ActiveSupport::Concern

  included do
    # Associations
    has_many :access_tokens, as: :bearer, class_name: 'Zaikio::AccessToken'
  end
end
