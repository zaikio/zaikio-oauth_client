module Search::Operator
  extend ActiveSupport::Concern

  included do
    searchable_fields :name
  end

  class_methods do
    def search_by(keywords)
      search_within_self(keywords: keywords)
    end
  end
end
