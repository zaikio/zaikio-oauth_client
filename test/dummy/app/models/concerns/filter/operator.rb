module Filter::Operator
  extend ActiveSupport::Concern

  included do
    scope :filter_by_legal_form, ->(legal_forms) {
      legal_forms = legal_forms.map { |l| "%#{l}%" }
      where('name ILIKE any ( array[?] )', [*legal_forms])
    }

    scope :filter_by_countries, ->(countries) {
      where(country: [*countries])
    }
  end

  class_methods do
    def filter_by(params)
      chain_filters(params, :legal_form, :countries)
    end

    def sorted_by(sorting)
      return all unless sorting

      direction = /desc$/.match?(sorting) ? 'desc' : 'asc'
      case sorting.to_s
      when /^created_at_/
        order("created_at #{direction}")
      end
    end

    def filter_options
      [
        {
          name: :legal_form,
          param: 'legal_form',
          options: ['AG', 'GmbH', 'SE'].map { |l| [l, l.downcase] }
        },
        {
          name: :countries,
          param: 'countries',
          options: ['Germany', 'Italy', 'UK'].map { |c| [c, c.downcase] }
        }
      ]
    end

    def sorting_options
      [
        [:newest, 'created_at_desc'],
        [:oldest, 'created_at_asc']
      ]
    end
  end
end
