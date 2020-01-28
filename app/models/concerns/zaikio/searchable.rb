module Zaikio::Searchable
  extend ActiveSupport::Concern

  included do |klass|
    # model specific searches reside in Concerns::Search::* modules
    include "Search::#{klass}".constantize
  end

  class_methods do
    def searchable_fields(*fields)
      @search_fields = allowed_fields(fields)
    end

    def allowed_fields(fields)
      fields.select { |f| f.to_s.in? attribute_names }
    end

    private

    def search_within_self(keywords:, fields: @search_fields)
      return all unless keywords

      # replace "*" with "%", prepend and append '%', remove duplicate '%'s
      keywords = keywords.downcase.split(/\s+/)
      keywords = keywords.map do |k|
        ('%' + k.tr('*', '%') + '%').gsub(/%+/, '%')
      end

      where(
        keywords.map do
          '(' + fields.map { |field| "#{field} ILIKE ?" }.join(' OR ') + ')'
        end.join(' AND '),
        *keywords.map { |k| [k] * fields.count }.flatten
      )
    end
  end
end
