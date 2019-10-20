module Zaiku
  module Remote
    class OrganizationMembership
      include Jeweler::Resource
      include Zaiku::Localize

      attributes :roles
      singleton_associations :person, :organization
    end
  end
end
