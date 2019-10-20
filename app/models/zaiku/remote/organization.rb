module Zaiku
  module Remote
    class Organization
      include Jeweler::Resource
      include Zaiku::Localize

      attributes :name
      associations :organization_memberships
    end
  end
end
