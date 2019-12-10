module Zaiku
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::RenderingHelper

    # Adds a cancel link to the form which closes the modal
    def cancel
      @template.link_to 'Cancel', '#', class: 'modal__cancel-btn', 'data-action': 'modal#cancel'
    end

    def error_messages(*attributes_to_show)
      attributes_to_show.any? ? error_messages_for(*attributes_to_show) : error_messages_for
    end

    def text_field(method, options = {})
      if options.delete(:multiple)
        name = "#{object_name}[#{method}][]"

        ApplicationController.render(
          partial: 'components/array_text_field',
          locals: {
            name: name,
            values: Array.wrap(object.public_send(method)),
            options: options
          }
        )

      else
        super
      end
    end

    def select(method, values, options = {}, html_options = {})
      if options.delete(:custom)
        ApplicationController.render(
          partial: 'components/custom_select',
          locals: {
            object_name: object_name,
            method: method,
            values: values,
            value: object.public_send(method),
            options: options
          }
        )

      else
        super
      end
    end

    def file_field(name, options = {})
      @template.tag.div(class: 'file-field', data: { 'controller': 'upload' }) do
        @template.tag.div(class: 'file-field__icon file-field__icon--upload', data: { 'target': 'upload.uploadIcon' }) +
          @template.tag.div(class: 'file-field__icon file-field__icon--ok u-is-hidden', data: { 'target': 'upload.saveIcon' }) +
          @template.tag.div(class: 'file-field__content') do
            @template.tag.strong do
              @template.tag.div(I18n.t('helpers.standard_form_builder.file_field.choose_file'), data: { 'target': 'upload.fileName' })
            end +
              @template.tag.div(I18n.t('helpers.standard_form_builder.file_field.upload_info'), data: { 'target': 'upload.uploadInfo' }) +
              @template.tag.div(I18n.t('helpers.standard_form_builder.file_field.save_info'), class: 'u-is-hidden', data: { 'target': 'upload.saveInfo' })
          end +
          super(name, options)
      end
    end

    def date_select(method, options = {}, html_options = {})
      @template.content_tag(:div, class: 'date-select') do
        super
      end
    end

    def error_messages_for(*attributes_to_show)
      return unless object.respond_to?(:errors) && object.errors.any?

      errors = @object.errors.map do |attribute, message|
        if attributes_to_show.empty? or attributes_to_show.include?(attribute)
          @template.content_tag(:li, @object.errors.full_message(attribute, message))
        end
      end.compact.join.html_safe

      unless errors.empty?
        @template.content_tag(:div, class: 'form-error') do
          @template.content_tag(:p, I18n.t('helpers.standard_form_builder.validation_errors')) +
            @template.content_tag(:ul, errors)
        end
      end
    end

    def country_select(attribute)
      self.select(
        attribute,
        Country.all.sort_by(&:localized_name).collect { |c| [c.localized_name, c.country_code] }
      )
    end

    def locale_select(attribute)
      self.select(
        attribute,
        I18n.available_locales.collect do |locale|
          [Person.human_attribute_name("locale.#{locale}"), locale]
        end
      )
    end

    def vue_component(component, props = {})
      tag.div data: { controller: :vue, component: component, props: props }
    end

    def autocomplete(attribute, url:, value_label:, submit: false, placeholder: nil, tabindex: nil, autofocus: false)
      name = "#{object_name}[#{attribute}]"
      vue_component :autocomplete,
                    url: url,
                    name: name,
                    initialValue: object.try(attribute),
                    label: value_label,
                    submit: submit,
                    placeholder: placeholder,
                    tabindex: tabindex,
                    autofocus: autofocus
    end
  end
end
