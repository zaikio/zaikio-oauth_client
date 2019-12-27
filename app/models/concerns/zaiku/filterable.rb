module Zaiku::Filterable
  extend ActiveSupport::Concern

  included do |klass|
    # model specific filtering reside in Concerns::Filter::* modules
    include "Filter::#{klass}".constantize
  end

  class_methods do
    def chain_filters(params, *filters)
      return all if params.blank?

      results = all
      filters.each do |filter|
        next if params[filter].blank?

        results = results.send("filter_by_#{filter}", params[filter])
      end
      results
    end
  end
end
