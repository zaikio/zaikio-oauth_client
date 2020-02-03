module Zaikio
  class Site < ApplicationRecord
    # Associations
    belongs_to :organization
  end
end
