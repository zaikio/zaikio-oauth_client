module Zaiku
  class Organization < ApplicationRecord
    # Concerns
    include TokenBearer
    
    # Associations
    has_many :memberships, class_name: 'Zaiku/OrganizationMembership', dependent: :destroy
    has_many :members, through: :memberships, source: :person

    # Validations
    validates :name, presence: true, uniqueness: true
  end
end
