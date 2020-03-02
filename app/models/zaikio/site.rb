module Zaikio
  class Site < ApplicationRecord
    self.table_name = "zaikio_sites"

    # Associations
    belongs_to :organization
  end
end
