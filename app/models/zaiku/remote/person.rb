module Zaiku
  module Remote
    class Person
      include Jeweler::Resource
      include Zaiku::Localize

      attributes :email, :first_name, :name
      associations :organization_memberships

      # Returns the person, including all organization memberships and their
      # respective organizations. This method will try to find all associated
      # objects locally first, if that fails, it will build the local object,
      # so person.save will trigger saving all associations as well.
      def to_local_person_with_associations
        self.to_local_person.tap do |local_person|
          local_person.memberships = self.organization_memberships.collect do |membership|
            membership.to_local_membership.tap do |local_membership|
              local_membership.person = local_person
              local_membership.organization = membership.organization.to_local_organization
            end
          end
        end
      end
    end
  end
end
