module Zaikio
  module Remote
    class Organization
      include Jeweler::Resource
      include Zaikio::Localize

      attributes :name
      associations :organization_memberships
    end
  end
end
