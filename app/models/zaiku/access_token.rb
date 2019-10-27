module Zaiku
  class AccessToken < ApplicationRecord
    # Associations
    belongs_to :bearer, polymorphic: true

    # Scopes
    scope :valid, -> { where('expires_at > :now', now: DateTime.now) }
  end
end
