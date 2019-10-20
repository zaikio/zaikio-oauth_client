module Zaiku
  module Remote
    class Person
      include Jeweler::Resource
      include Zaiku::Localize

      attributes :email, :first_name, :name
      associations :organization_memberships
    end
  end
end
