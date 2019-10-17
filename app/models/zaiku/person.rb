module Zaiku
  class Person < ApplicationRecord
    # Concerns
    include TokenBearer
    
    # Associations
    has_many :memberships, class_name: 'Zaiku/OrganizationMembership', dependent: :destroy
    has_many :organizations, through: :memberships

    # Validations
    validates :first_name, :name, presence: true
    validates :email, presence: true, uniqueness: true
  end
end
