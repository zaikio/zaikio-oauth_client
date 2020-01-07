module Zaiku
  module Remote
    class Person
      include Jeweler::Resource
      include Zaiku::Localize

      attributes :email, :first_name, :name, :locale, :time_zone
      associations :organization_memberships

      # Returns the person, including all organization memberships and their
      # respective organizations. This method will try to find all associated
      # objects locally first, if that fails, it will build the local object,
      # so person.save will trigger saving all associations as well.
      def to_local_person_with_associations(directory)
        self.to_local_person.tap do |local_person|
          local_person.memberships = self.organization_memberships.collect do |membership|
            membership.to_local_organization_membership.tap do |local_membership|
              local_membership.person = local_person
              local_membership.organization = membership.organization.to_local_organization
            end
          end

          # Add other collections that will be needed in general app context
          # directory.sites.collect do |site|
          #   site.to_local_site.tap do |local_site|
          #     local_site.organization = site.organization.to_local_organization
          #     local_site.save
          #   end
          # end
        end
      end
    end
  end
end
