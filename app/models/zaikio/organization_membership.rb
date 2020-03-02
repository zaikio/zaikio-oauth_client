module Zaikio
  class OrganizationMembership < ApplicationRecord
    self.table_name = "zaikio_organization_memberships"

    # Associations
    belongs_to :person
    belongs_to :organization

    # Validations
    validates :organization, uniqueness: { scope: :person }
  end
end
