module Zaiku
  module Remote
    class Site
      include Jeweler::Resource
      include Zaiku::Localize

      attributes :name
      singleton_associations :organization
    end
  end
end
