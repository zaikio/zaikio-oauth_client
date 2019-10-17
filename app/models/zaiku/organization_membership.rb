module Zaiku
  class OrganizationMembership < ApplicationRecord
    # Associations
    belongs_to :person
    belongs_to :organization

    # Validations
    validates :organization, uniqueness: { scope: :person }
  end
end
