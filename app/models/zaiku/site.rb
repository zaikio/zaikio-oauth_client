module Zaiku
  class Site < ApplicationRecord
    # Associations
    belongs_to :organization
  end
end
