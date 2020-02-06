module Zaikio
  module FormTagHelper
    def label_tag(name = nil, content_or_options = nil, options = nil, &block)
      if block_given? && content_or_options.is_a?(Hash)
        additional_options = content_or_options = content_or_options.stringify_keys
      else
        additional_options = options || {}
        additional_options = additional_options.stringify_keys
      end

      if additional_options
        tag.div(class: 'label-wrapper') do
          super(name, content_or_options, options) +
          if additional_options.has_key?('optional')
            tag.div(I18n.t('zaikio.forms.optional'), class: 'label-option label-option--optional')
          end +
          if additional_options.has_key?('more_link')
            tag.a(I18n.t('zaikio.forms.learn_more'), class: 'label-option label-option--link')
          end +
          if additional_options.has_key?('tooltip')
            tag.span(class: 'label-option label-option--tooltip', 'data-behavior': 'tooltip') do
              tag.div(additional_options['tooltip'], class: 'tooltip')
            end
          end
        end
      else
        super
      end
    end
  end
end