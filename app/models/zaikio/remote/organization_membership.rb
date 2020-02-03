module Zaikio
  module Remote
    class OrganizationMembership
      include Jeweler::Resource
      include Zaikio::Localize

      attributes :roles
      singleton_associations :person, :organization
    end
  end
end
