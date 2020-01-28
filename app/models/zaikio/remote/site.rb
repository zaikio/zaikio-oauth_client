module Zaikio
  module Remote
    class Site
      include Jeweler::Resource
      include Zaikio::Localize

      attributes :name
      singleton_associations :organization
    end
  end
end
